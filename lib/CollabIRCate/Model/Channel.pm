package CollabIRCate::Model::Channel;
use base qw/Catalyst::Model::DBIC::Schema/;

__PACKAGE__->config(
		    schema_class => 'CollabIRCate::Schema::Channel',
		    );
