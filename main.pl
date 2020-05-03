use strict;
use warnings;
use Getopt::Long;
use Time::Piece;
use Fcntl ':mode';


my $dir = '.';
my $long = 0;
my $own = 0;
GetOptions(
    'dir=s'     => \$dir,
    'long+'    => \$long,
    'own+' => \$own,
) or die "Incorrect usage!\n";
opendir(my $dh, $dir) || die "can't opendir $dir: $!";

foreach(sort{lc($a) cmp lc($b)} readdir($dh)){
    next if ($_ eq '.' || $_ eq '..');
    my $s_dir = "$dir/$_";
    my $result = "";
    if($long == 0){ $result .= $_;}
    elsif($long > 0){
        my ($mode, $mtime, $size) = stat($s_dir);
        my $modtime = localtime->strftime('%Y-%m-%d %H:%M:%S');
        my $mode_temp = sprintf ("%04o", (stat $s_dir)[2] & 07777);
        my $isDir = "";
        if(-f $s_dir){
            $isDir = "-"
        }
        if(-d $s_dir){
            $isDir = "d"
        }

        my $str_to_binary = "";
        
        for (my $i = 0; $i < length($mode_temp); $i++){
            my $c = substr($mode_temp, $i, 1);
            my $c_to_bin = sprintf("%.3b", $c);
            $str_to_binary .= $c_to_bin;
        }

        my $template = "rwxrwxrwx";
        $mode = $isDir;
        $str_to_binary = substr($str_to_binary, length($str_to_binary)-9);
        for (my $i = 0; $i < length($str_to_binary); $i++){
            if(substr($str_to_binary, $i, 1) == 1){
                $mode .= substr($template, $i, 1);
            }
            else{
                $mode .= "-";
            }
        }
        $result = sprintf("$_, $size, $modtime, $mode ");
        #print $_, " $size, $modtime, $mode\n";

        if($own > 0){
            my $owner = getpwuid((stat($s_dir))[4]);
            $result .= $owner;
        }
        print $result, "\n";
    }
}
closedir $dh;
