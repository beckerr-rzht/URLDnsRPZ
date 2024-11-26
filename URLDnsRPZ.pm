=head1 NAME

Mail::SpamAssassin::Plugin::URLDnsRPZ - Checks if the hostname
part of any url found in a email is DNS RPZ filtered

=head1 SYNOPSIS

 loadplugin Mail::SpamAssassin::Plugin::URLDnsRPZ URLDnsRPZ.pm

 body       URL_DNS_RPZ   eval:check_url_dnsrpz('^.*\.rpz\.(dfn\.de|switch\.ch)$')
 score      URL_DNS_RPZ   3.0
 describe   URL_DNS_RPZ   URL is filtered by DNS RPZ

=head1 DESCRIPTION

URLDnsRPZ is a plugin for SpamAssasin. It takes all URLs contained in a
email and resolves their hostname sequentially using DNS. The DNS response
is checked for having an "owner" in its "additions section". If this owner
matches an given regex the check terminates and returns a match.

The check function takes one mandatory and one optional argument:

 eval:check_url_dnsrpz(<regex>[,<linktype>)

 regex    - Regular expression to use for checking the "owner" listed in the
            "addition section" return from the DNS server. (mandatory)
 linktype - Type of URL to check. Valid types are 'a', 'img' and 'parsed'.
            See SpamAssain doumentation for more information.
            (optional, default is 'a')

=head1 LICENSE

Copyright (c) 2024 Ralf Becker

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished
to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

=head1 AUTHOR

Ralf Becker <beckerr@hochschule-trier.de>

=cut

package Mail::SpamAssassin::Plugin::URLDnsRPZ;
my $VERSION = "0.2";

use strict;
use Mail::SpamAssassin::Plugin;
use Net::DNS;

use vars qw(@ISA);
@ISA = qw(Mail::SpamAssassin::Plugin);


sub new {
	my ($class, $mailsa) = @_;
	$class = ref($class) || $class;
	my $self = $class->SUPER::new($mailsa);
	bless ($self, $class);
	$self->register_eval_rule("check_url_dnsrpz");
	$self->{area} = "URLDnsRPZ";
	return $self;
}

sub log {
	my $self = shift @_;
	my $level = shift @_;
	if ($level eq "debug") {
		Mail::SpamAssassin::Logger::dbg("$self->{area}: $_") foreach (@_);
	} else {
		Mail::SpamAssassin::Logger::log_message($level, "$self->{area}: $_") foreach (@_);
	}
}


sub dns_get_owner($) {
	my ($p) = @_;
	my $a = $p->{additional};
	return undef unless $a && ref($a) eq 'ARRAY' && scalar(@$a) > 0;
	return undef unless $a->[0]->{owner} && ref($a->[0]->{owner}) eq "Net::DNS::DomainName1035";
	return undef unless ref($a->[0]->{owner}->{label}) eq 'ARRAY';
	return join('.',@{$a->[0]->{owner}->{label}});
}

sub check_url_dnsrpz {
	my ($self, $permsgstatus, $ignore, $owner_match, $type) = @_;
	my $urls = $permsgstatus->get_uri_detail_list();
	my $resolver = Net::DNS::Resolver->new();

	foreach my $u (values %$urls) {

		next unless exists $u->{types}->{$type || 'a'};
		my ($url) =  @{$u->{cleaned}};

		next if $url !~ qr(^https?://(?:.*?@)?([^/:]*));
		my @nameparts = split/\./,$1;

		foreach my $i (0 .. scalar(@nameparts)-2) {

			my $query = join('.',@nameparts[$i..@nameparts-1]);
			$self->log('debug', "DNS $query?");

			my $owner = dns_get_owner($resolver->send($query));
			next unless defined($owner);

			$self->log('debug', "DNS $query has owner $owner");
			if ($owner =~ /$owner_match/i) {

				$self->log('info',"MATCH: DNS $query is filtered by owner $owner") ;
				$permsgstatus->_test_log_line("$query by $owner");
				return 1;
			} 
		}
	}
	0;
}

1;
