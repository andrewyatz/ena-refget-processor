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

package SeqIOFile;

use Moose::Role;
use Bio::SeqIO;
use Scalar::Util qw/openhandle/;

# Takes in $self, $record
requires 'process_record';
requires 'build_format';

has 'path'        => ( isa => 'Path::Tiny', is => 'ro', required => 1 );
has 'format'      => ( isa => 'Str', is => 'ro', required => 1, builder => 'build_format' );
has 'filehandle'  => ( isa => 'FileHandle', is => 'ro', lazy => 1, builder => 'build_filehandle' );
has 'reader'      => ( isa => 'Bio::SeqIO', is => 'ro', lazy => 1, builder => 'build_reader' );
has 'handler'     => ( isa => 'CodeRef', is => 'ro', required => 1 );

sub process {
  my ($self) = @_;
  my $reader = $self->reader();
  my $handler = $self->handler();
  while (my $record = $reader->next_seq()) {
    my @output = $self->process_record($record);
    $handler->(@output);
  }
  return;
}

sub build_filehandle {
	my ($self) = @_;
  my $path = $self->path();
  if($path->basename() =~ /\.gz$/) {
    my $cmd = sprintf('gzip -dc %s |', $path->stringify());
    open my $fh, "gzip -dc ${path} |" or confess "Cannot open $path for reading via gzip: $!";
    return $fh;
  }
  return $path->filehandle();
}

sub build_reader {
  my ($self) = @_;
  my $fh = $self->filehandle();
  return Bio::SeqIO->new(-fh => $fh, -format => $self->format());
}

sub DEMOLISH {
  my ($self) = @_;
  if(openhandle($self->filehandle())) {
    close $self->filehandle();
  }
  return;
}

1;
