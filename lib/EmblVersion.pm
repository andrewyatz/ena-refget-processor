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

package EmblVersion;

use Moose;

has 'accession'       =>  ( isa => 'Str', is => 'ro', required => 1 );
has 'sequenceVersion' =>  ( isa => 'Int', is => 'ro', required => 1 );
has 'firstPublic'     =>  ( isa => 'Str', is => 'ro', required => 1 );
has 'lastUpdated'     =>  ( isa => 'Str', is => 'ro', required => 1 );
has 'text'            =>  ( isa => 'Str', is => 'ro', required => 1 );
has 'fasta'           =>  ( isa => 'Str', is => 'ro', required => 0, predicate => 'has_fasta');
has 'status'          =>  ( isa => 'Str', is => 'ro', required => 1 );

__PACKAGE__->meta->make_immutable;

1;
