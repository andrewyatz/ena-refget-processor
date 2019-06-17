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

package Log::Reader;

use Moose;

with 'Log::CsvBase';

sub build_fh {
  my ($self) = @_;
  my $target = $self->target();
  if($target->is_file()) {
    return $target->openr();
  }
  confess "Cannot open filehandle because the target ${target} does not exist";
}

sub read_record {
  my ($self) = @_;
  my $fh = $self->fh();
  my $csv = $self->csv();
  my $row = $csv->getline($fh);
  return $row;
}

__PACKAGE__->meta->make_immutable;

1;
