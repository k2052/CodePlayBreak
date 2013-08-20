I love chess lets build a chess app. There is quite a good chess app call Pychess but it's python.
Let's build a new app from the ground up based on Pychess.

First off lets install Mercurial so we can clone the pychess repo and take a look at it:

```sh
sudo apt-get install mercurial
```

What to call our fork? Pillsbury is one of my favorite players and has never been used to name an app.
Lets call it Pillsbury

Lets make a dir for our project 

```sh
cd ~/creations && mkdir pillsbury
cd pillsbury
```

Now lets add a resources folder where we will stick pychess:

```sh
mkdir resources
```

Now lets cd into that directory and clone the pychess repo:

```sh 
cd resources
hg clone https://code.google.com/p/pychess/
```

Delight:
	Mercurial by default doesn't show progress bars during a clone. You can enable them by adding the following to your ~/.hgrc file.

	```conf
	[extensions]
	progress =
	```
