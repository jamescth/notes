import gdb
import sys
import inspect

vmcore = None

slab_ptr_type = gdb.lookup_type('struct slab').pointer()
skbuff_ptr_type = gdb.lookup_type('struct sk_buff').pointer()
void_ptr_type = gdb.lookup_type('void').pointer()
char_ptr_type = gdb.lookup_type('char').pointer()

def DBG(msg = ''):
	print >> sys.stderr, 'DBG at %d: %s' % (inspect.currentframe().f_back.f_lineno, msg)

def get_bits(map_name):
	arr = gdb.parse_and_eval(map_name)
	arr_type = arr.type
	assert arr_type.code == gdb.TYPE_CODE_ARRAY

	count = arr_type.sizeof / arr[0].type.sizeof
	
	ret = []
	for ai in range(count):
		bits = long(arr[ai])
		# TODO only 64 bits platform
		for i in range(64):
			if bits & (1 << i) != 0:
				ret.append(i + ai * 64)

	return ret

def traverse_list(head, func, type, list_field):
	bitpos = -1
	for f in type.fields():
		if f.name == list_field:
			bitpos = f.bitpos
			break
		node = head['next']
	if bitpos < 0:
		error()
		return

	offset = bitpos / 8 # 8 bits

	i = 0
	while node != head.address:
		ptr = node.cast(char_ptr_type) - offset
		func(i, ptr.cast(type.pointer()).dereference())
		node = node.dereference()['next']
		i += 1

def traverse_netdevice(func):
	head = gdb.parse_and_eval('dev_base_head')
	netdevice_type = gdb.lookup_type('struct net_device')
	traverse_list(head, func, netdevice_type, 'dev_list')


class Node:
	def __init__(self, cpus, start_pfn, mem_map):
		self.cpus = cpus
		self.start_pfn = start_pfn
		self.mem_map = mem_map
	def __repr__(self):
		return "NodeData(cpus=%s start_pfn=%lu mem_map=%s)" % (self.cpus, self.start_pfn, self.mem_map)

class Vmcore:
	def __init__(self):
		page_type = gdb.lookup_type('struct page')
		self.page_struct_size = page_type.sizeof

		self.phys_base = long(gdb.parse_and_eval("phys_base"))
		self.use_alien_caches = int(gdb.parse_and_eval("use_alien_caches"))
		self.numa_platform = int(gdb.parse_and_eval("numa_platform"))

		self.nodes = get_bits("node_online_map.bits")
		self.cpus = get_bits("cpu_online_map.bits")

		memnode = gdb.parse_and_eval('memnode')
		self.memnode_shift = int(memnode['shift'])

		memnode_mapsize = int(memnode['mapsize'])
		if memnode_mapsize == 0:
			memnode_mapsize = 64 - 16

		self.memnode_map_array = []
		memnode_map = memnode['map']
		for i in range(memnode_mapsize):
			self.memnode_map_array.append(int(memnode_map[i]))

		self.node_map = {}
		for node in self.nodes:
			cpus = get_bits('node_to_cpumask[%d].bits' % node)
			val = gdb.parse_and_eval('node_data[%d]' % node).dereference()
			self.node_map[node] = Node(cpus, int(val['node_start_pfn']), (val['node_mem_map']))
	

	def __repr__(self):
		return "CoreData(use_alien_caches=%d numa_platform=%d page_struct_size=%u, phys_base=%lx, memnode_shift=%u memnode_map=%s nodes=%s cpus=%s node_map=%s)" % (self.use_alien_caches, self.numa_platform, self.page_struct_size, self.phys_base, self.memnode_shift, self.memnode_map_array, self.nodes, self.cpus, self.node_map)

	def virt_to_page(self, va):
		if va >= 0xffffffff80000000:
			pa = va - 0xffffffff80000000 + self.phys_base
		else:
			pa = va - 0xffff810000000000
		pfn = pa >> 12
		nodeid = self.memnode_map_array[pa >> self.memnode_shift]
#		print "va=%lx pa=%lx pfn=%lx nodeid=%lx" % (va, pa, pfn, nodeid)
		nodedata = self.node_map[nodeid]
		return (nodedata.mem_map + self.page_struct_size * (pfn - nodedata.start_pfn), nodeid)

	def dump(self):
		print "linux numa_platform=%d use_alien_caches=%d phys_base=%lx" % (self.numa_platform, self.use_alien_caches, self.phys_base)
		for key, val in self.node_map.items():
			print "node %d %s start_pfn=%lu mem_map=%s" % (key, val.cpus, val.start_pfn, val.mem_map)

SLAB_END = 0xffffffff
class Slab:
	def __init__(self, kmem_cache, slab_ptr):
		slab_obj = slab_ptr.dereference()
		self.colouroff = int(slab_obj['colouroff'])
		self.inuse = int(slab_obj['inuse'])
		self.free = int(slab_obj['free'])
		self.nodeid = int(slab_obj['nodeid'])
		self.s_mem = slab_obj['s_mem']

		index_array = []

		slab_bufctl = slab_ptr[1].address.cast(gdb.lookup_type('kmem_bufctl_t').pointer())
		for i in range(kmem_cache.num):
			index_array.append(int(slab_bufctl[i]))

		free_flags = [ 1 ] * kmem_cache.num
		curr = self.free
		free_count = 0
		for i in range(kmem_cache.num):
			if curr == SLAB_END:
				break
			free_flags[curr] = 0
			free_count += 1
			curr = index_array[curr]
		if self.inuse + free_count != kmem_cache.num:
			warning("")

		self.free_flags = free_flags



	def __str__(self):
		return "slab %x list=%lx,%lx colouroff=%d s_mem=%lx inuse=%d free=x%x nodeid=%d index=%s count=%d" % (self.addr, self.next, self.prev, self.colouroff, self.s_mem,
		self.inuse, self.free, self.nodeid, array_to_string(self.index_array, "%08x", 8, 1), self.free_count)

def cache_table_insert(table, ptr, id):
	key = str(ptr)
	try:
		orig = table[key]
		warning("Key %s already be cached %s" % (key, orig))
	except:
		table[key] = [id, 0]

def load_array_cache(table, array_ptr, id):
	array_cache = array_ptr.dereference()
	avail = array_cache['avail']
	entry = array_cache['entry']
	for i in range(avail):
		cache_table_insert(table, entry[i], id)

skb_shared_info_ptr_type = gdb.lookup_type('struct skb_shared_info').pointer()
def dump_skb(skb, cache_id):
	dev = skb['dev']
	dev_iif = -1
	if dev:
		dev_iif = int(dev['ifindex'])
	skb_shinfo = skb['head'] + skb['end']
	skb_shinfo = skb_shinfo.cast(skb_shared_info_ptr_type).dereference()

	print "skb %s %s %s %d %d %04x %s %d %d %d %d %d %d %d %s %s %s %s %d" % (skb.address, skb['sk'], skb['head'].cast(void_ptr_type),
		skb['data'] - skb['head'],
		skb['pkt_type'], skb['protocol'], skb['dst'],
		skb['iif'], dev_iif,
		skb['len'], skb['data_len'],
		skb['tail'], skb['end'], skb['truesize'],
		skb['next'], skb['prev'], skb_shinfo['frag_list'],
		cache_id,
		skb['tstamp']['tv64'])


def dump_skb_1(skb):
	print "skb %s %s %s %d %04x %s %d %s %d" % (skb.address, skb['sk'], skb['head'].cast(void_ptr_type),
		skb['pkt_type'], skb['protocol'], skb['dst'],
		skb['iif'], skb['dev'], skb['len'])

def dump_slab_list(kmem_cache_obj, cached_table, nodeid, slab_list, p_or_f):
	end_addr = slab_list.address
	slab_ptr = slab_list['next']
	cached_count = 0

	while slab_ptr != end_addr:
		slab = Slab(kmem_cache_obj, slab_ptr.cast(slab_ptr_type))
		print "slab %s %s %d %s" % (slab_ptr, p_or_f, nodeid, slab.free_flags)

		i = 0
		obj_ptr = slab.s_mem
		for flag in slab.free_flags:
			if flag:
				cache_id = 3000
				try:
					cache_value = cached_table[str(obj_ptr)]
					if cache_value[1] != 0:
						warning('')
					cache_value[1] += 1
					cache_id = cache_value[0]
				except:
					pass

				
				if cache_id >= 3000:
					skb = obj_ptr.cast(skbuff_ptr_type).dereference()
					dump_skb(skb, str(cache_id))

			obj_ptr += kmem_cache_obj.buffer_size
			i += 1
				
		slab_ptr = slab_ptr.dereference()['next']



def traverse_slab_list(kmem_cache_obj, cached_table, nodeid, slab_list, p_or_f):
	end_addr = slab_list.address
	slab_ptr = slab_list['next']
	cached_count = 0

	while slab_ptr != end_addr:
		slab = Slab(kmem_cache_obj, slab_ptr.cast(slab_ptr_type))
		i = 0
		obj_ptr = slab.s_mem
		print "slab %s %s %d %s %s" % (slab_ptr, p_or_f, nodeid, obj_ptr, slab.free_flags)
		for flag in slab.free_flags:
			if flag and not kmem_cache_obj.cached_table.has_key(str(obj_ptr)):
				func(obj_ptr)

			obj_ptr += kmem_cache_obj.buffer_size
			i += 1
				
		slab_ptr = slab_ptr.dereference()['next']


class KmemCache:
	def __init__(self, vmcore, var_name):
		val = gdb.parse_and_eval(var_name).dereference()
		self.name = val['name'].string()
		self.batchcount = int(val['batchcount'])
		self.limit = int(val['limit'])
		self.shared = int(val['shared'])
		self.buffer_size = int(val['buffer_size'])
		self.reciprocal_buffer_size = int(val['reciprocal_buffer_size'])
		self.flags = int(val['flags'])
		self.num = int(val['num'])
		self.gfporder = int(val['gfporder'])

		self.kmem_cache = val

		#self.cached_table = None

	def load_cached(self, cached_table):
		#if self.cached_table:
		#	return

		array_caches = self.kmem_cache['array']
		for cpuid in vmcore.cpus:
			load_array_cache(cached_table, array_caches[cpuid], 1000 + cpuid)

		nodelists = self.kmem_cache['nodelists']
		for nodeid in vmcore.nodes:
			list3 = nodelists[nodeid].dereference()
			load_array_cache(cached_table, list3['shared'], 2000 + nodeid)

		#self.cached_table = cached_table

		#print "Cached number: %d" % len(cached_table)
		#print cached_table


	def check(self):
		load_cache(self)
		
	def traverse(self, cache):
		self.load_cached(cache)
		nodelists = self.kmem_cache['nodelists']
		for nodeid in vmcore.nodes:
			list3 = nodelists[nodeid].dereference()
			dump_slab_list(self, cache, nodeid, list3['slabs_partial'], 'P')
			dump_slab_list(self, cache, nodeid, list3['slabs_full'], 'F')


def traverse_qdisc_list(head, func):
	qdisc_type = gdb.lookup_type('struct Qdisc')
	traverse_list(head, func, qdisc_type, 'list')

def dump_netdev():
	# require load mod sch_htb
	htb_enqueue = gdb.parse_and_eval('htb_enqueue')
	u32_classify = gdb.parse_and_eval('u32_classify')
	def qdisc_dump(i, obj):
		qstats = obj['qstats']
		print "    #%d %d x%x x%x %d %d %d %d %d" % (i, obj['q']['qlen'], obj['handle'], obj['parent'],
			qstats['qlen'], qstats['backlog'], qstats['drops'], qstats['requeues'], qstats['overlimits'])
		if obj['enqueue'] == htb_enqueue:
			htb_sched_type = gdb.lookup_type('struct htb_sched')
			tc_u_hnode_type = gdb.lookup_type('struct tc_u_hnode')
			htb_sched = obj.address + 1
			htb_sched = htb_sched.cast(htb_sched_type.pointer()).dereference()
			print "    htb %d %d" % (htb_sched['filter_cnt'], htb_sched['now'])
			# traver_tcf_proto(htb_sched['filter_list'])
			tcf = htb_sched['filter_list']
			count = 0
			while tcf:
				tcf_obj = tcf.dereference()
				if tcf_obj['classify'] == u32_classify:
					hnode = tcf_obj['root'].cast(tc_u_hnode_type.pointer()).dereference()
					n = hnode['ht'][0]

					print "        #%d %s u32 %d x%x %d %s" % (count, tcf_obj.address,
						tcf_obj['protocol'],
						tcf_obj['prio'], tcf_obj['classid'], n)
					if n:
						n = n.dereference()
						nkeys = n['sel']['nkeys']
						keys = n['sel']['keys']
						for key_i in range(nkeys):
							key = keys[key_i]
							print "            #%d x%08x x%08x %d x%x" % (key_i,
								key['mask'], key['val'], key['off'], key['offmask'])
				else:
					print "        #%d unk %d x%x %d %s" % (count, tcf_obj.address,
						tcf_obj['protocol'],
						tcf_obj['prio'], tcf_obj['classid'], tcf_obj['classify'])
				count += 1
				tcf = tcf_obj['next']
		else:
			print "    UNKNOWN"

	def netdev_dump(i, obj):
		#print "netdev %s %s %d" % (obj.address, obj['name'].string(), obj['ifindex'])
		print "netdev %s %s %d %s" % (obj.address, obj['name'].string(), obj['ifindex'], obj['open'])
		qdisc_list = obj['qdisc_list']
		traverse_qdisc_list(qdisc_list, qdisc_dump)
	traverse_netdevice(netdev_dump)


def vmcore_init():
	global vmcore
	if vmcore:
		return
	vmcore = Vmcore()


def dump_ixgbe_ring_array(ring_array, number, rx_or_tx):
	total = 0
	for i in range(number):
		ring = ring_array[i].dereference()
		print '%s_ring %d' % (rx_or_tx, i)
		buffer_count = ring['count']
		buffer_info_array = ring[rx_or_tx + '_buffer_info']
		for bi in range(buffer_count):
			buffer_info = buffer_info_array[bi]
			skb = buffer_info['skb']
			if skb != 0:
				dump_skb(skb.dereference())
				total += 1
	print 'total_ring %s skb %d' % (rx_or_tx, total)

def collect_skb_list(skb_cache, skb, id):
	while skb != 0:
		cache_table_insert(skb_cache, skb, id)
		skb = skb.dereference()['next']
		
def collect_ixgbe_ring_skb(skb_cache, index, ring_array, number, rx_or_tx):
	if rx_or_tx == 'rx':
		rxtx = 4000
	else:
		rxtx = 5000

	for i in range(number):
		ring = ring_array[i].dereference()
		buffer_info_array = ring[rx_or_tx + '_buffer_info']
		if not buffer_info_array:
			break
		#print '%s_ring %d' % (rx_or_tx, i)
		buffer_count = ring['count']
		for bi in range(buffer_count):
			buffer_info = buffer_info_array[bi]
			skb = buffer_info['skb']
			collect_skb_list(skb_cache, skb, index * 1000000 + i * 10000 + rxtx + bi)
			if skb != 0:
				cache_table_insert(skb_cache, skb, index * 1000000 + i * 10000 + rxtx + bi)

def collect_ixgbe_ring(skb_cache):
	ixgbe_open = gdb.parse_and_eval('ixgbe_open')
	ixgbe_adapter_ptr_type = gdb.lookup_type('struct ixgbe_adapter').pointer()


	def collect(i, obj):
		# print "netdev %s %s %d %s" % (obj.address, obj['name'].string(), obj['ifindex'], obj['open'])
		if obj['open'] != ixgbe_open:
			return
		# this is ixgbe device
		priv = obj['priv']
		ixgbe_adapter = priv.cast(ixgbe_adapter_ptr_type).dereference()
		collect_ixgbe_ring_skb(skb_cache, obj['ifindex'],
				ixgbe_adapter['rx_ring'], int(ixgbe_adapter['num_rx_queues']), 'rx')
		collect_ixgbe_ring_skb(skb_cache, obj['ifindex'],
				ixgbe_adapter['tx_ring'], int(ixgbe_adapter['num_tx_queues']), 'tx')
		
	traverse_netdevice(collect)
"""
def collect_ixgbe_ring_skb(skb_cache, index, ring_array, number, rx_or_tx):
	if rx_or_tx == 'rx':
		rxtx = 4000
	else:
		rxtx = 5000

	for i in range(number):
		ring = ring_array[i].dereference()
		#print '%s_ring %d' % (rx_or_tx, i)
		buffer_count = ring['count']
		buffer_info_array = ring[rx_or_tx + '_buffer_info']
		for bi in range(buffer_count):
			buffer_info = buffer_info_array[bi]
			skb = buffer_info['skb']
			collect_skb_list(skb_cache, skb, index * 1000000 + i * 10000 + rxtx + bi)
"""
def dump_skb_list(skb, index, qi, rx_or_tx, bi):
	li = 0
	while skb != 0:
		skb = skb.dereference()
		dump_skb(skb, "%d-%d-%s-%d-%d" % (index, qi, rx_or_tx, bi, li))
		skb = skb['next']
		li += 1

def dump_ixgbe_ring_skb(index, ring_array, number, rx_or_tx):
	if rx_or_tx == 'rx':
		rxtx = 4000
	else:
		rxtx = 5000

	for qi in range(number):
		ring = ring_array[qi].dereference()
		buffer_count = ring['count']
		buffer_info_array = ring[rx_or_tx + '_buffer_info']
		for bi in range(buffer_count):
			buffer_info = buffer_info_array[bi]
			skb = buffer_info['skb']
			dump_skb_list(skb, index, qi, rx_or_tx, bi)

def dump_ixgbe_skb():
	ixgbe_open = gdb.parse_and_eval('ixgbe_open')
	ixgbe_adapter_ptr_type = gdb.lookup_type('struct ixgbe_adapter').pointer()

	def collect(i, obj):
		if obj['open'] != ixgbe_open:
			return
		# this is ixgbe device
		priv = obj['priv']
		ixgbe_adapter = priv.cast(ixgbe_adapter_ptr_type).dereference()
		dump_ixgbe_ring_skb(obj['ifindex'],
				ixgbe_adapter['rx_ring'], int(ixgbe_adapter['num_rx_queues']), 'rx')
		dump_ixgbe_ring_skb(obj['ifindex'],
				ixgbe_adapter['tx_ring'], int(ixgbe_adapter['num_tx_queues']), 'tx')
		
	traverse_netdevice(collect)


def dump_slab_skbuff():
	vmcore_init()
	vmcore.dump()

	dump_netdev()

	skb_cache = {}
	collect_ixgbe_ring(skb_cache)

	print "skbuff_head_cache"
	skbuff_head_cache = KmemCache(vmcore, 'skbuff_head_cache')
	
	skbuff_head_cache.traverse(skb_cache)

	print "skbuff_fclone_cache"
	skbuff_fclone_cache = KmemCache(vmcore, 'skbuff_fclone_cache')
	
	skbuff_fclone_cache.traverse(skb_cache)

	for key, val in skb_cache.items():
		if val[1] != 1:
			print "cache_miss", key, val[0], val[1]



def test(file_name):
	for line in open(file_name).xreadlines():
		line = line.rstrip()
		skb = gdb.parse_and_eval('(struct sk_buff *)' + line)
		dump_skb(skb.dereference(), "")


"""
	vmcore_init()
	vmcore.dump()

	dump_netdev()

	dump_ixgbe_skb()

	skb_cache = {}
	collect_ixgbe_ring(skb_cache)
	for key, id in skb_cache.items():
		print key, id
def load_cache(kmem_cache_obj):
	cached_table = {}
	ulong_type = gdb.lookup_type('unsigned long')
	array_caches = kmem_cache_obj.kmem_cache['array']
	for cpuid in vmcore.cpus:
		load_array_cache(cached_table, array_caches[cpuid], cpuid)

	nodelists = kmem_cache_obj.kmem_cache['nodelists']
	for nodeid in vmcore.nodes:
		list3 = nodelists[nodeid].dereference()
		load_array_cache(cached_table, list3['shared'], 10000 + nodeid)

	print "Cached number: %d" % len(cached_table)
	#print cached_table

	for nodeid in vmcore.nodes:
		list3 = nodelists[nodeid].dereference()
		
		dump_slab_list(kmem_cache_obj, cached_table, nodeid, list3['slabs_partial'], 'P')
		dump_slab_list(kmem_cache_obj, cached_table, nodeid, list3['slabs_full'], 'F')

ixgbe_lro_desc_type = gdb.lookup_type('struct ixgbe_lro_desc')
def dump_lro_desc_list(hlist_head):
	node = hlist_head['first']
	count = 0
	while node != 0:
		print 'node =', node
		lro_desc = node.cast(ixgbe_lro_desc_type.pointer()).dereference()
		skb = lro_desc['skb']
		if skb != 0:
			dump_skb(skb.dereference())
			count += 1
		node = node.dereference()['next']
	return count

def dump_ixgbe_adapter(var_name):
	ixgbe_adapter = gdb.parse_and_eval('(struct ixgbe_adapter *)' + var_name)
#	dump_ixgbe_ring_array(ixgbe_adapter['rx_ring'], int(ixgbe_adapter['num_rx_queues']), 'rx')
#	dump_ixgbe_ring_array(ixgbe_adapter['tx_ring'], int(ixgbe_adapter['num_tx_queues']), 'tx')

	q_vector_array = ixgbe_adapter['q_vector']
	num_msix_vectors = ixgbe_adapter['num_msix_vectors']

	total_lro_skb = 0
	for qi in range(num_msix_vectors - 1):
		q_vector = q_vector_array[qi].dereference()
		lrolist = q_vector['lrolist'].dereference()
		print qi, lrolist
		active_count = dump_lro_desc_list(lrolist['active'])
		free_count = dump_lro_desc_list(lrolist['free'])
		print 'q_vector #%d %d %d' % (qi, active_count, free_count)
		total_lro_skb += active_count
		total_lro_skb += free_count
	print 'total_lro %d' % total_lro_skb
"""

