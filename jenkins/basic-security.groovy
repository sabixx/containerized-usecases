#!/usr/bin/env groovy
import jenkins.model.*
import hudson.security.*

// Get the Jenkins instance
def instance = Jenkins.getInstance()

// Retrieve the admin password from the environment variable or use a default
def adminPassword = System.getenv('ADMIN_PASSWORD') ?: 'defaultAdminPassword'

// Create admin user and set the password
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount('admin', 'admin') 
instance.setSecurityRealm(hudsonRealm)

// Set the authorization strategy
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)

// Mark Jenkins as fully initialized and skip the configuration dialog
instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)

// Save the configuration
instance.save()
