import {Application} from '@hotwired/stimulus';
import NotificationController from './notification_controller';

const application = Application.start ();

// Configure Stimulus development experience
application.debug = true; // Enable debug mode to help troubleshoot
window.Stimulus = application;

// Register controllers
application.register ('notification', NotificationController);

export {application};
