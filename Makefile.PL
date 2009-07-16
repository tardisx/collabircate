# IMPORTANT: if you delete this file your app will not work as
# expected.  you have been warned
use inc::Module::Install;

name 'CollabIRCate';
all_from 'lib/CollabIRCate.pm';

requires 'DBIx::Class';

requires 'SQL::Translator';

requires 'Catalyst::Runtime' => '5.7014';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Model::DBIC::Schema';
requires 'Catalyst::View::TT';

requires 'Module::Pluggable';
requires 'REST::Google';

requires 'DateTime';
requires 'Path::Class';
requires 'FindBin';
requires 'Mail::Send';
requires 'MIME::Parser';
requires 'URI::Find';

requires 'File::Temp' => 0.18;

requires 'POE' => 1.006;
requires 'POE::Component::IRC' => 6.08;
requires 'POE::Component::Server::IRC';

requires 'parent';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats

catalyst;

install_script glob('script/*.pl');
auto_install;
my $tests = join (' ', glob("t/*.t"), glob("t/*/*.t"));
WriteMakefile(test => {TESTS => $tests});
