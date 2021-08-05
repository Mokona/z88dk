#!/usr/bin/env perl

use Modern::Perl;
use Test::More;
use Capture::Tiny 'capture_merged';
use Path::Tiny;

use vars '$test';
$test = "test_".(($0 =~ s/\.t$//r) =~ s/[\.\/]/_/gr);

sub check_bin_file {
    my($got_file, $exp) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    
    run_ok("xxd -g1 $got_file > $got_file.hex");
    
    my $exp_file = ($got_file =~ s/\.\w+$/.exp/ir);
    path($exp_file)->spew_raw($exp);
    run_ok("xxd -g1 $exp_file > $exp_file.hex");
    
    run_ok("diff $exp_file.hex $got_file.hex");
}

sub check_txt_file {
    my($got_file, $exp) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    
    my $exp_file = ($got_file =~ s/\.\w+$/.exp/ir);
    path($exp_file)->spew($exp);
    
    run_ok("dos2unix -q $exp_file $got_file");
    run_ok("diff $exp_file $got_file");
}

sub z80asm_ok {
    my($options_files, @pairs) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    
    # build $asm and $bin
    my($asm, $bin) = ("","");
    while (my($a, $b) = splice(@pairs, 0, 2)) {
        $asm .= "$a\n";
        $bin .= $b;
    }
    
    # save asm file
    my $asm_file = "${test}.asm";
    my $bin_file = "${test}.bin";
    path($asm_file)->spew($asm);
    unlink($bin_file);
    
    # assemble
    $options_files ||= "-b";
    my($options, $files) = split(/\|/, $options_files);
    $files ||= $asm_file;

    run_ok("./z88dk-z80asm $options $files");
    check_bin_file($bin_file, $bin);
}

sub capture_ok {
    my($cmd, $exp_out) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    
    run_ok($cmd." > ${test}.out");
    check_txt_file("${test}.out", $exp_out);
}

sub capture_nok {
    my($cmd, $exp_err) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    run_ok($cmd." 2> ${test}.err");
    check_txt_file("${test}.err", $exp_err);
}

sub run_ok {
    my($cmd) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    ok 0==system($cmd), $cmd;
}

sub run_nok {
    my($cmd) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    ok 0!=system($cmd), $cmd;
}

sub bytes { return pack("C*", @_); }
sub words { return pack("v*", @_); }
sub words_be { return pack("n*", @_); }
sub pointers {
    my $bin = "";
    for (@_) {
        $bin .= pack("vC", $_ & 0xFFFF, ($_ >> 16) & 0xFF);
    }
    return $bin;
}
sub dwords { return pack("V*", @_); }

sub unlink_testfiles {
    unlink(<${test}*>) 
        if Test::More->builder->is_passing;
}

1;
