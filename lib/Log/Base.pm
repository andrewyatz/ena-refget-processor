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

package Log::Base;

use Moose::Role;
use DateTime::Tiny;

requires 'headers';
requires 'columns';

has 'timestamp' => ( isa => 'DateTime::Tiny', is => 'ro', required => 1, default => sub { return DateTime::Tiny->now(); });
has 'metadata'  => ( isa => 'Metadata', is => 'ro', required => 1 );

1;
