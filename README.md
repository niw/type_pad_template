TypePad Temlpate
----------------

This is gem and command interface to manipulate TypePad advanced templates from command line.

Usage
=====

Install gem which provides ``type_pad_tamplate`` command.

    gem install type_pad_template

To see the usage, use help command.

    type_pad_template help

Download and upload templates
=============================

First you need to login to typepad using your email address and password.

    type_pad_template login -u 'your-email@address'

Then list blogs on your account to get a blog id.

    type_pad_template blogs

To download, upload templates, use each command with ``-b`` option.

    type_pad_template download -b 'your-blog-id'
    type_pad_template upload -b 'your-blog-id'
