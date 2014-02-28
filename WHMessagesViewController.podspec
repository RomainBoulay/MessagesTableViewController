Pod::Spec.new do |s|
	s.name				= 'WHMessagesViewController'
	s.version			= '1.0.1'
	s.summary			= 'A messages UI for iPhone and iPad.'
	s.homepage			= 'https://github.com/RomainBoulay/MessagesTableViewController'
	s.social_media_url	= 'https://twitter.com/r_boulay'
	s.license			= 'MIT'
	s.authors			= { 'Romain Boulay' => 'romain.boulay@gmail.com' }
	s.source			= { :git => 'https://github.com/RomainBoulay/MessagesTableViewController.git', :tag => s.version.to_s }
	s.platform			= :ios, '6.0'
	s.source_files		= 'WHMessagesViewController/Classes/**/*'
	s.frameworks		= 'QuartzCore'
	s.requires_arc		= true
end
