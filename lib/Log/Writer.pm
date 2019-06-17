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

package Log::Writer;

use Moose;
use Scalar::Util qw/blessed/;

with 'Log::CsvBase';

has 'first_line'  => ( isa => 'Bool', is => 'rw', default => 0 );
has 'headers'     => ( isa => 'ArrayRef', is => 'rw', predicate => 'has_headers' );

sub build_fh {
  my ($self) = @_;
  my $target = $self->target();
  my $fh;
  if($target->is_file()) {
    confess "Cannot open filehandle because the target ${target} already exists";
  }
  else {
    $target->touchpath();
    $fh = $target->openw();
  }
  return $fh;
}

sub write {
  my ($self, $log) = @_;

  my $fh = $self->fh();
  my $csv = $self->csv();
  my $headers;
  if(! $self->has_headers()) {
    $headers = $self->headers($log->headers());
    $csv->say($fh, $headers);
  }
  else {
    $headers = $self->headers();
  }

  my $columns = $log->columns();
  if(! defined $columns) {
    return; # if columns is not defined then skip the write
  }

  my $header_count = scalar(@{$headers});
  my $col_count = scalar(@{$columns});
  if($header_count != $col_count) {
    my $log_instance = blessed($log);
    confess "Cannot process Log instance ${log_instance}. Expected column count is ${header_count} but detected column count was ${col_count}";
  }

  return $csv->say($fh, $columns);
}

__PACKAGE__->meta->make_immutable;

1;
