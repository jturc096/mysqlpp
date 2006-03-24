#!/usr/bin/perl -w

########################################################################
# querydef.pl - Generates querydef.h, which defines a number of macros
#	used in query.h that differ only in the number of arguments.  That
#	number limits the number of parameters a MySQL++ template query can
#	accept.  This value can be changed from its default, below.
#
# Copyright (c) 2006 by Educational Technology Resources, Inc.  Others
# may also hold copyrights on code in this file.  See the CREDITS file
# in the top directory of the distribution for details.
#
# This file is part of MySQL++.
#
# MySQL++ is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation; either version 2.1 of the License, or
# (at your option) any later version.
#
# MySQL++ is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
# License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with MySQL++; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301
# USA
########################################################################


# The number of parameters a template query can accept.  Make this value
# larger only at need, as it adds code to the library proportionally.
# You should not reduce this value if programs you did not write may
# link to the library, as that would constitute an ABI breakage.
my $max_parameters = 25;


# No user-serviceable parts below.

use strict;

open (OUT, ">querydef.h");

print OUT << "---";
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// This file is generated by the Perl script querydef.pl. Please do 
// not modify this file directly. Change the script instead.
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

#ifndef MYSQLPP_QUERYDEF_H
#define MYSQLPP_QUERYDEF_H

---

## Build mysql_query_define0 macro
print OUT "#define mysql_query_define0(RETURN, FUNC) \\\n";
for (my $i = 0; $i < $max_parameters; ++$i) {
	print OUT "\tRETURN FUNC(";
	for (my $j = 0; $j < $i + 1; ++$j) {
		print OUT 'const SQLString& arg', $j;
		print OUT ', ' unless $j == $i;
	}
	print OUT ") \\\n";

	print OUT "\t\t{ return FUNC(SQLQueryParms()";
	for (my $j = 0; $j < $i + 1; ++$j) {
		print OUT ' << arg', $j;
	}
	print OUT "); } \\\n";
}

## Add mysql_query_define1 macro
print OUT << "---";

#define mysql_query_define1(RETURN, FUNC) \\
	MYSQLPP_EXPORT RETURN FUNC(SQLQueryParms& p); \\
	mysql_query_define0(RETURN, FUNC)
---

## Add mysql_query_define2 macro
print OUT << "---";

#define mysql_query_define2(FUNC) \\
	template <class T> void FUNC(T& container, const char* str); \\
	template <class T> void FUNC(T& container, SQLQueryParms& p, \\
  		query_reset r = RESET_QUERY); \\
---
for (my $i = 0; $i < $max_parameters; ++$i) {
	print OUT "\ttemplate <class T> void FUNC(T& container";
	for (my $j = 0; $j < $i + 1; ++$j) {
		print OUT ', const SQLString& arg', $j;
	}
	print OUT ") \\\n";
	print OUT "\t\t{ FUNC(container, SQLQueryParms()";
	for (my $j = 0; $j < $i + 1; ++$j) {
		print OUT ' << arg', $j;
	}
	print OUT "); } \\\n";
}

## That's all, folks!
print OUT "\n#endif // !defined(MYSQLPP_QUERYDEF_H)\n";

