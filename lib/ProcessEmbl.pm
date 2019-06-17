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

package ProcessEmbl;

use Moose;
use ProcessSeq;
use ProcessMetadata;

has 'sequence_store_path' => ( isa => 'Path::Tiny', is => 'ro', required => 1 );
has 'metadata_store_path' => ( isa => 'Path::Tiny', is => 'ro', required => 1 );

with 'SeqIOFile';

sub process_record {
  my ($self, $seq) = @_;
  my $metadata = ProcessMetadata->new(seq => $seq, store_path => $self->metadata_store_path())->process();
  my $seq_obj = ProcessSeq->new(seq => $seq, metadata => $metadata, store_path => $self->sequence_store_path());
  my $seq_path = $seq_obj->process();
  $metadata->seq_path($seq_path);
  return $metadata;
}

__PACKAGE__->meta->make_immutable;

1;
