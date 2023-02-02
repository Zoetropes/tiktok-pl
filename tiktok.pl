#!/usr/bin/perl
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <https://unlicense.org>

use LWP;
use HTTP::Request;
use Unicode::Escape;

$|=1;
my $ua=LWP::UserAgent->new(keep_alive=>0,timeout=>10);
$ua->agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36");

sub get_tt {
  my $id=shift;
  $id=$1 if ($id=~/video\/(\d+)/);
  my $res=$ua->get("https://api16-core-c-useast1a.tiktokv.com/aweme/v1/feed/?aweme_id=$id&version_name=1.0.4&version_code=104&build_number=1.0.4&manifest_version_code=104&update_version_code=104&openudid=4dsoq34x808ocz3m&uuid=6320652962800978&_rticket=1671193816600&ts=1671193816&device_brand=POCO&device_type=surya&device_platform=android&resolution=1080*2179&dpi=440&os_version=12&os_api=31&carrier_region=US&sys_region=US%C2%AEion=US&app_name=TikMate%20Downloader&app_language=en&language=en&timezone_name=Western%20Indonesia%20Time&timezone_offset=25200&channel=googleplay&ac=wifi&mcc_mnc=&is_my_cn=0&aid=1180&ssmix=a&as=a1qwert123&cp=cbfhckdckkde1");
  my $aweme_id=$1 if ($res->content=~/"aweme_id":"(.+?)"/smg);
  my $create_time=$1 if ($res->content=~/"create_time":(\d+)/smg);
  my $unique_id=$1 if ($res->content=~/"unique_id":"(.+?)"/smg);
  my $url_list=$1 if ($res->content=~/video.+?play_addr.+?url_list.+?\[(.+?)\]/smg);
  return undef unless ($aweme_id&&$create_time&&$unique_id&&$url_list);
  $url_list=Unicode::Escape::unescape($url_list);
  $url_list=~s/"//mg;
  my @urls=split(/,/,$url_list);
  my $fn=$unique_id."-".$aweme_id.".mp4";
  foreach $url (@urls) {
    print "$unique_id [$aweme_id]... ";
    my $req=HTTP::Request->new("GET",$url);
    my $res=$ua->request($req,$fn);
    if ($res->code()==200) {
      utime($create_time,$create_time,$fn);
      print "OK\n";
      return;
    }
    print "Retrying... ";
  }
  print "Failed.\n";
}

if ($#ARGV<0) {
  print "Usage: $0 [-i] <url or id> ... [url or id]\n\n   -i for interactive mode, one URL or ID per line\n\n";
  exit(0);
}
if (@ARGV[0] eq "-i") {
  for (;;) {
    print "tiktok> ";
    my $ln=<STDIN>; chomp($ln); chomp($ln);
    $ln=$1 if ($ln=~/^\s+(.+)$/); $ln=$1 if ($ln=~/^(.+)\s+$/);
    exit(0) if ($ln eq "exit");
    get_tt($ln);
  }
} else {
  foreach (@ARGV) {
    get_tt($_);
  }
}
