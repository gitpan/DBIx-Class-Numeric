=head1 NAME

DBIx::Class::Numeric - add helper methods for numeric columns

=head1 SYNOPSIS

package MyApp::Schema::SomeTable;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/Core Numeric/); # Load the Numeric component

__PACKAGE__->add_columns(
    qw/primary_id some_string num_col1 num_col2/
);

__PACKAGE__->numeric_cols(qw/num_col1 num_col2/); # List any cols that need the extra functionality

# ... meanwhile, after reading a record from the DB

$row->increase_num_col1(5); # Add 5 to num_col1

$row->decrease_num_col2(9); # Subtract 9 from num_col2

$row->adjust_num_col1(-5); # Subtract 5 from num_col1
						   # (can be positive or negative, as can increase/decrease...
						   #  adjust is just a clearer name...) 

$row->increment_num_col1; # Increment num_col1

$row->decrement_num_col2; # Decrement num_col2

=head1 DESCRIPTION

A simple DBIx::Class component that adds five methods to any numeric columns in a schema class.

=head1 METHODS

=head2 numeric_cols(@cols)

Call this method as you would add_columns(), and pass it a list of columns that are numeric. Note,
you need to pass the column names to add_columns() *and* numeric_cols().

=head2 increase_*, decrease_*, increment_*, decrement_*, adjust_*

These 5 self-explanatory methods are added to your schema class for each column you pass to numeric_cols() 

=head1 AUTHOR

Sam Crawley (Mutant) - mutant dot nz at gmail dot com

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

package DBIx::Class::Numeric;

use strict;
use warnings;

our $VERSION = '0.001';

use base qw(DBIx::Class);

use Sub::Name ();

sub numeric_columns {
	my $self = shift;
	my @cols = @_;

	foreach my $col (@cols) {
		my %methods = (
			adjust => sub {
				_adjust($col, @_);	
			},
			increase => sub {
	    		_increase($col, @_);
	    	},
	    	decrease => sub {
	    		_decrease($col, @_);
	    	},
	    	increment => sub {
	    		_increment($col, @_);
	    	},
	    	decrement => sub {
	    		_decrement($col, @_);
	    	} 
		);
   	
    	while (my ($method_name, $subref) = each %methods) {
    		no strict 'refs';
    		no warnings 'redefine';
    				
	    	my $name = join '::', $self, "${method_name}_$col";
      		*$name = Sub::Name::subname($name, $subref);
    	}
		
	}		
}

sub _increase {
	my $col = shift;
	my $self = shift;
	my $increase = shift;

	$self->set_column($col, ($self->get_column($col) || 0) + ($increase || 0));	
}

sub _decrease {
	_increase($_[0], $_[1], -$_[2]);	
}

sub _increment {
	_increase($_[0], $_[1], 1);	
}

sub _decrement {
	_decrease($_[0], $_[1], 1);	
}

sub _adjust {
	_increase(@_);	
}

1;