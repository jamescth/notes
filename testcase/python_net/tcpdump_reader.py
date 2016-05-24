from __future__ import with_statement  # Only needed on very old python versions

import os
import re
import sys 
import itertools


path_to_file = 'tcpdump.txt'
line_parser = re.compile(r'(\d*\.\d*.\d*.\d*)(\.\d*) > (\d*\.\d*.\d*.\d*)(\.\d*)')


def parse_line(line):  # renamed from four_tuple
    match = line_parser.search(line)
    if match:
        source_ip, source_port, dest_ip, dest_port = match.groups()  # Use tuple unpacking to get the variables.
        return {  # A dictionary where each item is given it's own key: value pair.
            u'source_ip': source_ip, u'source_port': source_port,
            u'dest_ip': dest_ip, u'dest_port': dest_port,
            u'line': line,
        }
    else:
        return None  # We'll check for a bad match later!

def main():
    parsed_results = []  # We need a place to store our parsed_results from your matcher function.
    if not os.path.exists(path_to_file):  # Only if we can see the file
        print u'Error, cannot load file: {0}'.format(path_to_file)
        sys.exit(1)
    else:
        with open(path_to_file, 'r') as src_file:  # Using the with context, open that file. It will be auto closed when we're done.
            for src_line in src_file:  # for each line in the file
                results = parse_line(src_line)  # run it through your matcher function.
                if results:
                    parsed_results.append(results)  # Place the results somewhere for later grouping and reporting
                else:
                    print u'[WARNING] Unable to find results in line: "{0}"'.format(repr(src_line))  # Show us the line, without interpreting that line at all.
    # By now, we're done with the src_file so it's auto-closed because of the with statement
    if parsed_results:  # If we have any results to process
        # Sort those results by source_ip
        sort_func = lambda x: x.get(u'source_ip')  # We will sort our dictionary items by the source_ip key we extracted earlier in parse_line
        # First, we have to sort our results so source_ip's are joined together.
        sorted_results = sorted(parsed_results, key = sort_func)
        # Now, we group by source_ip using the same sort_func
        grouped_results = itertools.groupby(sorted_results, key = sort_func)
        # Here, grouped_results will return a generator which will yield results as we go over it
        #   However, it will only yield results once. You cannot continually iterate over it like a list.
        for source_ip, results in grouped_results:  # The iterator yields the grouped key, then a generator of results on each iterating
            for result in results:  # So, for each result which was previously grouped.
                print(u'The Source IP and Port are: {0} {1}'.format(result.get(u'source_ip'), result.get(u'source_port')))
                print(u'The Destination IP and Port are: {0} {1}'.format(result.get(u'dest_ip'), result.get(u'dest_port')))

if __name__ == u'__main__':  # This will only execute if this script is run from the command line, and not when it's loaded as a module.
    main()

