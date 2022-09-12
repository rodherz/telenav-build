#!/usr/bin/env perl

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

use 5.018;
use strict;
use warnings;
use File::Basename;
use feature qw(switch);
no warnings qw(experimental::smartmatch);
use FindBin;

our $build_dry_run;

sub cactus
{
    my $command = shift @_;
    my @arguments = (@_);

    my @defaults = (); # ("--quiet");
    push @arguments, @defaults;
    push @arguments, "-Dcactus.scope=all com.telenav.cactus:cactus-maven-plugin:${\(cactus_version())}:${command}";
    push @arguments, "validate";

    cd_workspace();
    maven_array(\@arguments);
}

sub dry_run
{
    $build_dry_run = 1;
}

sub is_dry_run
{
    return $build_dry_run;
}

sub workspace
{
    my $workspace = $ENV{TELENAV_WORKSPACE};
    if (! defined $workspace)
    {
        fail("TELENAV_WORKSPACE must be defined");
    }
    return $workspace;
}

sub cactus_version
{
    my $version;
    if ($ENV{'KIVAKIT_DEBUG'})
    {
        $version = `cat ${\(workspace())}/cactus/pom.xml | grep -Eow '<cactus\.version>(.*?)</cactus\.version>' | sed -E 's/.*>(.*)<.*/\\1/'`;
    }
    else
    {
        $version = `cat ${\(workspace())}/cactus/pom.xml | grep -Eow '<cactus\.previous\.version>(.*?)</cactus\.previous\.version>' | sed -E 's/.*>(.*)<.*/\\1/'`;
    }
    chomp $version;
    return $version;
}

sub cd_workspace
{
    chdir workspace() || fail("Cannot change folders to ${\(workspace())}");
}

sub maven
{
    maven_array(\@_);
}

sub maven_array
{
    my @arguments = @{$_[0]};

    my $log_level = $ENV{"MAVEN_LOG_LEVEL"};
    if (!defined $log_level)
    {
        $log_level = "info";
    }

    my $temporary_folder = $ENV{"TMPDIR"};
    if (!defined $temporary_folder)
    {
        $temporary_folder = "/tmp";
    }
    $temporary_folder =~ s/\/$//;

    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime();
    $sec = "unused";
    $yday = "unused";
    $isdst = "unused";
    my @weekdays = ("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun");
    my $weekday = $weekdays[$wday];
    $year += 1900;
    my $log_file = sprintf("${temporary_folder}/maven-$weekday-$year.%02d.%02d-$hour.%02d-%s.log", $mon, $mday, $min, basename($0));

    my $arguments = join(" ", @arguments);
    my $command = "mvn -Dorg.slf4j.simpleLogger.logFile=\"${log_file}\" -Dorg.slf4j.simpleLogger.defaultLogLevel=\"${log_level}\" -Dorg.slf4j.simpleLogger.cacheOutputStream=false $arguments 2>&1";
    my $exit_code = 0;
    if (defined $build_dry_run && $build_dry_run eq 1)
    {
        say_it("Execute: $command");
    }
    else
    {
        $exit_code = system($command);
    }

    my $last_log_link = "$temporary_folder/maven-last.log";
    `rm -f "$last_log_link"`;
    `ln -s "$log_file" "$last_log_link"`;

    if ($exit_code != 0)
    {
        fail(qq!
The Maven command

    $command

failed with exit code ${exit_code}. A complete log is in ${log_file}.
The last maven log is always $temporary_folder/maven-last.log
!);
    }
}

sub say_it
{
    my ($text) = @_;
    println("┋ $text");
}

sub println
{
    my ($text) = @_;
    print "$text\n";
}

sub fail
{
    my ($text) = @_;
    println $text;
    exit 1;
}

sub fail_with_usage
{
    my $help = shift @_;

    fail("Usage: $FindBin::Script $help");
}

sub require_variable
{
    my ($variable, $help) = @_;
    if (!defined $ENV{$variable})
    {
        fail_with_usage($help);
    }
}

sub say_it_block
{
    my ($text) = @_;
    print "\n$text\n\n";
}

sub console_input
{
    my $prompt = shift @_;
    print($prompt);
    my $input = <STDIN>;
    chomp $input;
    return $input;
}

sub get_argument
{
    my $prompt = shift @_;

    if (@ARGV == 0)
    {
        return console_input($prompt);
    }
    elsif (@ARGV == 1)
    {
        return shift @ARGV;
    }
    else
    {
        return undef;
    }
}

1;
