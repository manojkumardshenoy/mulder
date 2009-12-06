#!/usr/bin/perl

use strict;
use IO::Handle;

my $srcdir=$ARGV[0];
if(! defined($srcdir))
{
	print "srcdir not defined, using avidemux\n";
	$srcdir="avidemux";
}

my $in  = "$srcdir/prefs.in";
my $h   = "$srcdir/prefs.h";
my $cpp = "$srcdir/ADM_libraries/ADM_utilities/prefs.cpp";
#print "In:$in\n";
my $h_str = "typedef enum {\n";
my $cpp_str = "typedef enum {\n".
              "\tUINT,\n".
              "\tINT,\n".
              "\tULONG,\n".
              "\tLONG,\n".
              "\tFLOAT,\n".
              "\tSTRING,\n".
              "\tFILENAME\n".
              "} types;\n".
              "\n".
              "typedef struct {\n".
              "\tconst char *name;\n".
              "\ttypes type;\n".
              "\tconst char *default_val;\n".
              "\tchar *current_val;\n".
              "\tconst char *minimum;\n".
              "\tconst char *maximum;\n".
              "} opt_def;\n".
              "\n".
              "static opt_def opt_defs [] = {\n";

my $fd = new IO::Handle;
my @data;
my $flag;
my $num_opts = 0;
my $prev_optname = "";

open($fd,"< $in") or die;
while(<$fd>){
	chomp;
	s/^(#\s.*|#$)//;
	next if( /^[ 	]*$/ );
	#     optname       type           value  rest
	if( /^([^,]+)\s*,\s*([A-Z]+)\s*,\s*([^,]+)(.*)$/ ){
		my ($N,$a,$b,$c,$d,$e) = ($1,uc($1),$2,$3,$4,$4);
		$a       =~ s/\./_/g;
		$cpp_str .= "\t{\"$N\",";
		$cpp_str .= "\t" if( length($c)%8 != 3 );
		$cpp_str .= "\t$b,";
		if(( $b eq "STRING" )||($b eq "FILENAME")){
			$c =~ s/^"//;
			$c =~ s/"$//;
                        $c =~ s/@/,/; # Replace % by , needed by alsa stuff

		}else{
			$cpp_str .= "\t";
		}
		$cpp_str .= "\"$c\",";
		$cpp_str .= "\t" if( length($c) < 5 );
		$cpp_str .= "NULL,";
		# max min processing
		if(( $b eq "STRING" )||($b eq "FILENAME")){
			$cpp_str .= " NULL, NULL },\n";
		}else{
			$d =~ s/^\s*,\s*//;
			($d,$e) = split(",",$d);                        
			$d =~ s/\s*$//;
			$e =~ s/^\s*//;
			$e =~ s/\s*$//;
			$cpp_str .= "\t\"$d\",";
			$cpp_str .= "\t" if( length($d) < 5 );
			$cpp_str .= "\"$e\"";
			$cpp_str .= "\t" if( length($e) < 5 );
			$cpp_str .= "},\n";
			die "value($a) < min : $c < $d\n" if( $c < $d );
		}

		if ($prev_optname ne $N){
			$h_str .= "\t$a,\n";
			$num_opts++;
			$prev_optname = $N;
		}
	}else{
		if ( /^#/ ){
			$cpp_str .= "$_\n";
		}
		else {
			die "parse error in \"$in\" line \"$_\".";
		}
	}
}
close($fd);

$h_str    = substr($h_str,0,-2); # strip out ",\n"
$h_str   .= "\n} options;\n";
$cpp_str  = substr($cpp_str,0,-2); # strip out ",\n"
$cpp_str .= "\n};\n\nint num_opts = $num_opts;\n";

@data = ();
$flag = 0;
open($fd,"< $h") or die;
while(<$fd>){
	if( /^\/\/ <\/prefs_gen>/ ){
		$flag = 2;
	}
	if( $flag == 0 || $flag == 2 ){
		push @data,$_;
	}
	if( /^\/\/ <prefs_gen>/ ){
		$flag = 1;
		push @data,$h_str;
	}
}
close($fd);
open($fd,"> $h") or die;
print $fd join("",@data);
close($fd);

@data = ();
$flag = 0;
open($fd,"< $cpp") or die($cpp);
while(<$fd>){
        if( /^\/\/ <\/prefs_gen>/ ){
                $flag = 2;
        }
        if( $flag == 0 || $flag == 2 ){
                push @data,$_;
        }
        if( /^\/\/ <prefs_gen>/ ){
                $flag = 1;
                push @data,$cpp_str;
        }
}
close($fd);
open($fd,"> $cpp") or die;
print $fd join("",@data);
close($fd);

exit(0);
