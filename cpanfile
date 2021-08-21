requires 'perl', '5.008001';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Trap';
    requires 'File::Temp';
};

requires 'feature';
requires 'open';
requires 'parent';
requires 'Class::Accessor';
requires 'Encode';
requires 'Exporter';
requires 'File::Basename';
requires 'Getopt::Std';
requires 'Data::Clone';
