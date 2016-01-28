#!/usr/bin/env perl 
# (c) 2015-2015 Difrex <difrex.punk@gmail.com>

use strict;
use warnings;

use Search::Elasticsearch;

use II::Config;
use II::Get;
use Encode qw(decode encode);

my $config = II::Config->new()->load();
my $get = II::Get->new($config);
my @data = $get->get_echo();


# Connect to localhost:9200:
my $e = Search::Elasticsearch->new(
    nodes => [$config->{elastic_host}]
);

foreach my $message (@data) {
    if ($message) {
        my $body = {
                post    => decode("UTF-8", $message->{post}),
                subg    => decode("UTF-8", $message->{subg}),
                message => decode("UTF-8", $message->{post}),
                date    => $message->{time},
                author  => decode("UTF-8", $message->{from_user}),
                to      => decode("UTF-8", $message->{to_user}),
                echo    => $message->{echo},
                msgid   => $message->{hash}

        };

        # Index post
        print localtime . ": Indexing message" . $message->{hash} . "\n";
        $e->index(
            index   => $config->{elastic_index},
            type    => 'post',
            id      => $message->{hash},
            body    => $body
        );

    }
}
 
print localtime . " Done\n";

