# ------------------------------------------------------------------------------
# usage: ls_part_slab
# warnings: check nodeid, change idx before use this func
# ------------------------------------------------------------------------------
# all the kmem_cache are created via kmem_cache_create() & stores in cache_chain
define ls_part_slab
	# calculate list offset in kmem_cache
	set $list_kmem_cache = (long)(&((struct kmem_cache*)0)->next)
	set $head = &cache_chain
	set $cur = $head->next
	#printf "head is %p\n", $head
	#printf "cur is %p\n", $cur

	while $cur != $head
		# the starting addr of each kmem_cache = the next addr - offset
		set $kmem_cache = (struct kmem_cache*)(((long)$cur) - $list_kmem_cache)
		printf "===========================================================\n"
		printf "%p %s\n", $kmem_cache, $kmem_cache->name
		printf "num %12d slab_size %4d colour %4d colour_off %5d\n", $kmem_cache->num, $kmem_cache->slab_size, $kmem_cache->colour, $kmem_cache->colour_off
		printf "batchcount %5d limit %8d shared %4d buffer_size %4d\n", $kmem_cache->batchcount, $kmem_cache->limit, $kmem_cache->shared, $kmem_cache->buffer_size
		printf "gfpflags %7d dflags %7d gfporder %2d flags %10d\n", $kmem_cache->gfpflags, $kmem_cache->dflags, $kmem_cache->gfporder, $kmem_cache->flags
		printf "reciprocal_buffer_size %d slabp_cache %p\n", $kmem_cache->reciprocal_buffer_size, $kmem_cache->slabp_cache

		# set up index to walkthrough notelists => MAX_NUMNODES
		# the current size is 64.  use 'struct -o kmem_cache'

		# node id: it's the numa node.  check the code to verify what the max id is
		# node_online_map
		# p {struct pglist_data} node_data[0] & [1]
		set $idx = 0
		while $idx < 4
			set $kmem_list = $kmem_cache->nodelists[$idx]

			# walkthrough partial list
			if $kmem_list
				printf "======================================================================\n"
				printf "%d kmem_list3 %p free_obj %4ld free_limit %4d part %p full %p empty %p\n", $idx, $kmem_list, $kmem_list->free_objects, $kmem_list->free_limit, $kmem_list->slabs_partial->next, $kmem_list->slabs_full->next, $kmem_list->slabs_free->next
				set $cur_slab = $kmem_list->slabs_partial->next
				while $cur_slab != $kmem_list
					set $slab = (struct slab*)$cur_slab
					printf "%p inuse %3d free %3d nodeid %2d\n", $slab, $slab->inuse, $slab->free, $slab->nodeid
					set $cur_slab = $slab->list->next
				end
			end


			set $idx = $idx + 1
		end 
		printf "\n"
		set $cur = $cur->next
	end
end
document ls_part_slab
  list slabs
end

define ls_part_slab_still_working
	# calculate list offset in kmem_cache
	set $list_kmem_cache = (long)(&((struct kmem_cache*)0)->next)
	set $head_cache = &cache_chain
	set $cur_kcache = $head_cache->next
	#printf "head_cache is %p\n", $head_cache
	#printf "cur_kcache is %p\n", $cur_kcache

	while $cur_kcache != $head_cache
		# the starting addr of each kmem_cache = the next addr - offset
		set $kmem_cache = (struct kmem_cache*)(((long)$cur_kcache) - $list_kmem_cache)
		printf "===========================================================\n"
		printf "%p %s\n", $kmem_cache, $kmem_cache->name
		printf "num %12d slab_size %4d colour %4d colour_off %5d\n", $kmem_cache->num, $kmem_cache->slab_size, $kmem_cache->colour, $kmem_cache->colour_off
		printf "batchcount %5d limit %8d shared %4d buffer_size %4d\n", $kmem_cache->batchcount, $kmem_cache->limit, $kmem_cache->shared, $kmem_cache->buffer_size
		printf "gfpflags %7d dflags %7d gfporder %2d flags %10d\n", $kmem_cache->gfpflags, $kmem_cache->dflags, $kmem_cache->gfporder, $kmem_cache->flags
		printf "reciprocal_buffer_size %d slabp_cache %p\n", $kmem_cache->reciprocal_buffer_size, $kmem_cache->slabp_cache

		# set up index to walkthrough notelists => MAX_NUMNODES
		# the current size is 64.  use 'struct -o kmem_cache'

		# node id: it's the numa node.  check the code to verify what the max id is
		# node_online_map
		# p {struct pglist_data} node_data[0] & [1]
		set $idx = 0
		while $idx < 1
			set $kmem_list = $kmem_cache->nodelists[$idx]

			printf "full list\n"
			if $kmem_list->slabs_full->next == &($kmem_list->slabs_full)
				printf "full list is empty\n"
			else
				ls_slab_list $kmem_list->slabs_full->next &($kmem_list->slabs_full)
			end

			printf "\nfree list\n"
			if $kmem_list->slabs_free->next == &($kmem_list->slabs_free)
				printf "free list is empty\n"
			else
				ls_slab_list $kmem_list->slabs_free &($kmem_list->slabs_free)
			end

			# walkthrough partial list
			printf "\nPartial list\n"
			if $kmem_list->slabs_partial->next == &($kmem_list->slabs_partial)
				printf "Partial list is empty\n"
			else
				ls_slab_list $kmem_list->slabs_partial->next &($kmem_list->slabs_partial)
			end

			set $idx = $idx + 1
		end 
		printf "\n"
		set $cur_kcache = $cur_kcache->next
	end
end
document ls_part_slab_still_working
  list slabs
end

define ls_kmem_cache_array
	# calculate list offset in kmem_cache
	set $list_kmem_cache = (long)(&((struct kmem_cache*)0)->next)
	set $head = &cache_chain
	set $cur = $head->next
	while $cur != $head
		# the starting addr of each kmem_cache = the next addr - offset
		set $kmem_cache = (struct kmem_cache*)(((long)$cur) - $list_kmem_cache)
		printf "kmem_cache: %p %20s limit %4d num %5d\n", $kmem_cache, $kmem_cache->name, $kmem_cache->limit, $kmem_cache->num

		# need to get the cpu num from 'cpu_online_map', and calculate the bit
		printf "    addr           cpu avail limit bct  th entry\n"
		set $cpu = 0
		while $cpu < 16
			set $array = (struct array_cache*)((long)$kmem_cache->array[$cpu])
			printf "%p %2d %4d  %4d %4d %4d %p\n", $array, $cpu, $array->avail, $array->limit, $array->batchcount, $array->touched, $array->entry
			set $cpu = $cpu+1
		end
		set $cur = $cur->next
	end
end
document ls_kmem_cache_array
  list kmem_cache
end

define ls_slab_list
	set $cur_slab = $arg0
	set $tail = $arg1

	
	printf "%p %p\n", $cur_slab, $tail
	while $cur_slab != $tail
		set $slab = (struct slab*)$cur_slab
		printf "%p inuse %3d free %4d nodeid %2d\n", $slab, $slab->inuse, $slab->free, $slab->nodeid
		set $cur_slab = $slab->list->next
	end

end
document ls_slab_list
  list ls_slab_list
end

# ------------------------------------------------------------------------------
# usage: ls_struct_kcache <kmem_cache>
# warnings: check nodeid, change idx before use this func
# ------------------------------------------------------------------------------
# list content of a given kmem_cache
# $arg0: struct kmem_cache *
#
# dependency: call ls_slab_list() to list 
define ls_struct_kcache
	set $struct_kmem_cache = (struct kmem_cache*)$arg0
	printf "%p %s\n", $struct_kmem_cache, $struct_kmem_cache->name
	printf "num %12d slab_size %4d colour %4d colour_off %5d\n", $struct_kmem_cache->num, $struct_kmem_cache->slab_size, $struct_kmem_cache->colour, $struct_kmem_cache->colour_off
	printf "batchcount %5d limit %8d shared %4d buffer_size %4d\n", $struct_kmem_cache->batchcount, $struct_kmem_cache->limit, $struct_kmem_cache->shared, $struct_kmem_cache->buffer_size, 
	printf "gfpflags %7d dflags %7d gfporder %2d flags %10d\n", $struct_kmem_cache->gfpflags, $struct_kmem_cache->dflags, $struct_kmem_cache->gfporder, $struct_kmem_cache->flags
	printf "reciprocal_buffer_size %d slabp_cache %p\n", $struct_kmem_cache->reciprocal_buffer_size, $struct_kmem_cache->slabp_cache

	# revisit: need to get the cpu num from 'cpu_online_map', and calculate the bit
	printf "================================================\n"
	printf "    addr           cpu avail limit bct  th entry\n"
	set $cpu = 0
	while $cpu < 16
		set $array = (struct array_cache*)((long)$struct_kmem_cache->array[$cpu])
		printf "%p %2d %4d  %4d %4d %4d %p\n", $array, $cpu, $array->avail, $array->limit, $array->batchcount, $array->touched, $array->entry
		set $cpu = $cpu+1
	end

	printf "=====================================================================================\n"
	printf "        kmem_list3     free_obj free_limit part               full               free\n"

	# revisit: idex is the nodeid, need to find what the global is, and use it instead
	# use 'mach -cpu | grep node' to get how many nodes
	set $idx = 0	
	# get slab lists
	while $idx < 4
		set $kmem_list = (struct kmem_list3*)$struct_kmem_cache->nodelists[$idx]

		# revisit: for crash 6.0, we cant use $kmem_list->slabs_partial->next, need to redefine the variable
		printf "%3d %p %4ld     %4d       %p %p %p\n", $idx, $kmem_list, $kmem_list->free_objects, $kmem_list->free_limit, $kmem_list->slabs_partial->next, $kmem_list->slabs_full->next, $kmem_list->slabs_free->next

		printf "full list\n"
		if $kmem_list->slabs_full->next == &($kmem_list->slabs_full)
			printf "full list is empty\n"
		else
			ls_slab_list $kmem_list->slabs_full->next &($kmem_list->slabs_full)
		end

		printf "\nfree list\n"
		if $kmem_list->slabs_free->next == &($kmem_list->slabs_free)
			printf "free list is empty\n"
		else
			ls_slab_list $kmem_list->slabs_free &($kmem_list->slabs_free)
		end

		# walkthrough partial list
		printf "\nPartial list\n"
		if $kmem_list->slabs_partial->next == &($kmem_list->slabs_partial)
			printf "Partial list is empty\n"
		else
			ls_slab_list $kmem_list->slabs_partial->next &($kmem_list->slabs_partial)
		end

		set $idx = $idx + 1
	end 

end
document ls_struct_kcache
  list skbuff head
end

