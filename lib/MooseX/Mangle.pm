package MooseX::Mangle;
use Moose ();
use Moose::Exporter;

sub mangle_args {
    my $caller = shift;
    my ($method_name, $code) = @_;
    my $meta = Class::MOP::class_of($caller);
    $meta->add_around_method_modifier($method_name => sub {
        my $orig = shift;
        my $self = shift;
        my @args = $self->$code(@_);
        return $self->$orig(@args);
    });
}

sub mangle_return {
    my $caller = shift;
    my ($method_name, $code) = @_;
    my $meta = Class::MOP::class_of($caller);
    $meta->add_around_method_modifier($method_name => sub {
        my $orig = shift;
        my $self = shift;
        if (wantarray) {
            my @ret = $self->$orig(@_);
            return $self->$code(@ret);
        }
        else {
            my $ret = $self->$orig(@_);
            return $self->$code($ret);
        }
    });
}

Moose::Exporter->setup_import_methods(
    with_caller => [qw(mangle_args mangle_return)],
);

1;
