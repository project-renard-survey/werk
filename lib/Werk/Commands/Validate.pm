package Werk::Commands::Validate {
	use MooseX::App::Command;

	with 'MooseX::Log::Log4perl';

	sub run {
		my $self = shift();
	}

	__PACKAGE__->meta()->make_immutable();
}

1;
