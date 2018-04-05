nwdeploy
========

About
-----
Git push to deploy! On your Servers!  Woah!  Where are my billions?

Description
-----------

A module to install Postgres, and setup a directory structure for your web app under /home/{app_name}

Example
-------

	node 'optimusprimal' {
	    include nwdeploy
	    nwdeploy::basic('kuhero')
	    nwdeploy::db('kuhero', 'password123isagoodpassword!')
	}

Miscellaneous
=============

You probably shouldn't be using this, I haven't touched it in 6 years?  Dunno if it is Puppetic or whatever they call puppet code.

Author
------

* Jawaad Mahmood <jawaad.mahmood@gmail.com>
