#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

package Log::CsvBase;

use Moose::Role;
use Text::CSV;

requires 'build_fh';

has 'target'      => ( isa => 'Path::Tiny', is => 'ro', required => 0 );
has 'fh'          => ( isa => 'FileHandle', is => 'ro', lazy => 1, builder => 'build_fh' );
has 'csv'         => ( isa => 'Text::CSV', is => 'ro', required => 1, lazy => 1, builder => 'build_csv');
has 'separator'   => ( isa => 'Str', is => 'ro', required => 1, default => qq{,} );

sub build_csv {
  my ($self) = @_;
  my $separator = $self->separator();
  my $csv = Text::CSV->new({ binary => 1, eol => $/, sep_char => $separator });
  return $csv;
}

1;
