use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	        => 'Algorithm::Permute',
    'VERSION_FROM'  => 'Permute.pm', # finds $VERSION
    'LIBS'	        => [''],   # e.g., '-lm' 
    'DEFINE'	    => '-DPERL_EXT',     # e.g., '-DHAVE_SOMETHING' 
    'INC'	        => '',     # e.g., '-I/usr/include/other' 
    'OBJECT'        => 'coolex.o Permute.o',
    'CCFLAGS'       => '-Wall',
);
