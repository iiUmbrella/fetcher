package II::Config;

use Config::Tiny;
use LWP::UserAgent;
use HTTP::Request;
use Data::Dumper;

sub new {
    my $class = shift;

    my $self = { _file => 'config.ini', };

    bless $self, $class;
    return $self;
}

# Load configuration
sub load {
    my ($self) = @_;
    my $file = $self->{_file};
    
    my $tiny = Config::Tiny->new();
    $config = $tiny->read($file);

    my $key       = $config->{auth}->{key};
    my $nick      = $config->{auth}->{nick};
    my $host      = $config->{node}->{host};
    my @echoareas = split /,/, $config->{node}->{echoareas};
    my $name      = $config->{node}->{name};

    if ( $config->{node}->{list} eq 'yes' ) {
        @echoareas = echo_from_list($host);
    }

    $c = {
        nick      => $nick,
        key       => $key,
        host      => $host,
        echoareas => [@echoareas],
        name      => $name,
        elastic_host => $config->{elastic}->{host},
        elastic_index => $config->{elastic}->{index},
    };

    return $c;
}

# Make echoareas list from list.txt
sub echo_from_list {
    my ($host) = @_;

    my $list = $host . 'list.txt';
    my @echoes;

    my $ua = LWP::UserAgent->new();
    $ua->agent("Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0)");

    my $req = HTTP::Request->new( GET => $list );
    my $res = $ua->request($req);

    if ( $res->is_success ) {
        my @e = split /\n/, $res->content();
        while (<@e>) {
            my @description = split /:/, $_;
            push @echoes, $description[0];
        }
    }

    return @echoes;
}

1;
