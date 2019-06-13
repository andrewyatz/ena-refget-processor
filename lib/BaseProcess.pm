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

package BaseProcess;

use Moose::Role;

has 'store_path' => ( isa => 'Path::Tiny', is => 'ro', required => 1 );
has 'remove_mismatches' => ( isa => 'Bool', is => 'ro', required => 1, default => 0 );

sub get_target_dir {
  my ($self, $metadata) = @_;
  my $trunc512 = $metadata->trunc512();
  my ($one, $two, $three) = $trunc512 =~ /\w{2}/g;
  my $target_dir = $self->store_path()->child($one)->child($two)->child($three);
  $target_dir->mkpath();
  return $target_dir;
}

sub check_content {
  my ($self, $target, $expected_md5) = @_;
  my $roundtrip_digest = $target->digest( { chunk_size => 10e6 }, 'MD5' );
  if($roundtrip_digest ne $expected_md5) {
    if($self->remove_mismatches()) {
      $target->remove();
    }
    confess("Roundtrip write check failed. Content at '${target}' did not match expected MD5 digest ${expected_md5}. Was ${roundtrip_digest}.");
  }
}

1;