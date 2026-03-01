This website is called `bartering.games` which is the domain that users will visit for this website.

I would like to build a website that enables gamers to trade their steam keys. This repo is the inital repository to begin planning
this website. We may need other repositories based on the requirements below. The goal of this project is to primarily only interface
with open-spec.

While we build this initial plan we should create a CLAUDE.md at the root of this project with the information which will be useful to future claude chats where we are implementing features on this project. Examples include: How we run integartion tests, what the coding language is, what the best coding practices are, how we lint/clean our code before we make a git commit (automate this process pre-commit is an example but there may be better tooling)


The most important considerations for this project are:
- Infrastructure
  - Based on the below requirements, I first want to work with you on the best infrastructure and coding language/framework
    Whatever we choose should be well established and have good documentation.
- User interface
  - I would like for the website to be very seamless. When using the website in mobile mode it should feel smooth and responsive. 
    When using it in the desktop the website should instead have an interface geared towards mouse and keyboard.
- Testability is a #1 concern.
  - We should create an framework easily testable by agentic coding agents.
  - We need to have good integration tests. This means we should utilize tools like docker to setup great integration tests.
  - We should also be able to test this website by using tools which can automate browsers. I want your advice on what tooling is is the best right now for browser automation.
  - I want to use Github actions to setup ci/cd that enforces best coding practices (in python you would use the mypy library, or other tools for good code enforcement). It should also run the unit and integration tests. We DO NOT NEED TO RUN the browser tests in ci/cd right now.
- Security
  - I would like to allow for users to sign in with their steam account. The user profile information that is exposed fia
    the steam integration should be stored for future use, if there is personal information this should be encrypted.
  - I would like for users to be able to create an encrypted wallet address to store their steam keys. This wallet address
     should not be readable by me and the website should explain how this is possible. It must be made clear that if they
     lose their wallet address, they will not be able to recover their steam keys.
- High level decisions
  - This project will rely heavily on steam integration. We should create an abstracted interface which represents the game synced from Steam, so that if we needed to sync from other data sources, we would just need to have that data source match the abstracted interface and allow for a swap of the syncing portion of this backend.
  - We need a very easy and cheap way to deploy this code. Ideally it would make it possible to swap between cloud compute hosts (aws, azure, etc) on a moments notice (we should plan for migrations of systems if necessary. Downtime of up to 4 hours during these migrations would be OK)
  - At this point I am open to frameworks and programming language suggestions. Based on these proposed features I want a very  economical way to host this website for the public. 
  - I would like to build into this plan a way to make money to at least pay for the hosting. The best way for this may be Google  Ads, but I do not hav experience monetizing a website, so suggestions are welcome. I do not want for there to be subscription  fees, this website should be free to users.
  - Users should be able to store their Steam (and other stores such as Epic or GOG) keys in the system. When they first begin this process they should be able to keep a string which they hold, and only them old. They should be informed that we have encrypted their steam keys so that if this website even had a security compromise, their keys would not be lost. It should be very clear that if they lose access to these keys they would lose access to their steam key library on this website.
  - Our games database should come from steam, There are websites which are able to somehow scrape steam (I think this may be via steamdb, we should investigate if they have a CLI, API, library, etc that we can). 
  - While our primary data source for games that exist come from steam, we should allow for user submissions. We should try to keep the data model between a Steam imported game very similar to a user imported game for maintainability in the future
  - When users search for a game for trading steam keys, they should be able to see:
    - a user interface that enables them to quickly find a trade partner who wants to trade for that games steam key.
    - The ability to store a steam key that they own, it is important that we allow for them to set an "expiration date" on this key
      as Humble Bundle has begun to set key expiration dates.
  - There are ways which sites have knowledge of what video game bundles have currently been sold. We should investigate if there is an API to find out this informatino for our database, as it would be a useful dropdown when a user is saving a steam key to present them with options that will pre-fill the useful fields such as "expiration date", "allowed regions", etc.
   - If there is no public API for this information, we should build a way for users to submit bundle information to the website.
- Background sync processes:
  - Steam library sync for users
  - (if possible/api available) We can sync bundle information which will be used when users are entering steam keys, etc
- Onboarding user flow:
  - User logs into the website, the only login option is steam (but we should plan for other options in the future)
    - We should ask for minimal information from the user, but a useful would be what "region" are they in for steam keys. Some keys are not available in all regions so we should allow for a feature which filters out keys which are not in regions the key will work with
    - We have a system that will import their steam library into our database once they authenticate with steam, this should be able to categorize the gamers
      into at least the following categories:
      - Owned games
      - Wishlist games - This should be pre-filled with the Steam wishlist, and we should allow for the user to sync with Steam on demand (in user settings)
        as well as us importing and syncing these changes on a regular basis (to steams usage allowance) to update their wishlist on the site.
        They should be able to add games to wishlists on barter-gates as well
      - We should explore other categories that steam (or steamdb) exposes which could be useful
    - We need to support other categories such as:
      - The owned games/Wishlist games above would be categories which are sync'd from Steam. I also need to support other categories,
        the first example category are the games which they own Steam keys for. I need a smooth onboarding process that will
        explain how the system is secure (see Security and High level Decisions section), and will allow them to search for games using the Steam games database
      - Are there other categories which could be useful? Do you have any good ideas? Either way we should plan on supporting these well for the future.
    - They are prompted to enable push notifications, we should explain this is to send notifications when they get trades from other users (or other items we come up with in the future, it will not be spammy). This option will be available in the user settings as well so they can enable or disable easily as necessary. They also can enter an email address into the website so that we can send them email notifications as necessary.
    - Now that the user has their steam profile imported they can use our interface to search for a game. On this interface they can find a steam key trade partner for this key. 
      - We should also have an algorithm which will display other users on the website who do owned the searched for game, and are interested in games that the logged in users actually owns. This would allow them to easily find users which own games they are interested in to initiate a trade
      - Can I work with you on finding other useful search criteria?
    - Once they send a trade request the other user on the website will be notified if the allowed the push notifications, or emails, in the onboarding process (or enabled in their user settings later). 
    - The other user who recieves the trade notification should be able to accept/reject/counter. I will define the following below:
      - Accept: They accepted the trade! if both keys are stored in the wallet we could allow for them to be shown immediatly to both users. Otherwise the users will have easy access to the other users steam profile so that they can chat and perform the trade 
      - Reject: this is an outright rejection of the offer. The offer should just result in "rejected" status and the logged in user gets a notification about the rejection
      - Counteroffer: The user can send a counteroffer with a different combination of the steam keys which the logged in user owns.
    - User case 1: User has counteroffer:
      - User can accept counter offer, go to user case 2
      - User can "reject". A terminal state of the offer.
      - User can counteroffer themselves with the same UI that allows users to choose from what games a user owns steam keys for.
    - User case 2: User has an accept for an offer:
      - The steam keys are automatically shown if both users have their steam keys stored in the website securely.
      - Otherwise there is a modal which pops up which shows the steam profile, where the users can chat and finish the trade
      - This modal should have a place for "user feedback". The feedback shoud consist of a "positive" a "negative" and a comment.
    - User has an accepted offer and has completed a trade:
      - THe user feedback in the trade process is accumulated against the user. Each user should have a profile which clearly displays total user feedback over timeframes such as past 1 week, past 1 month, and past 1 year. The profile should also have obvious things like a link to the steam profile, a display of what games they own, with easy filters like what platform that key is owned for.
- Saving a steam key to their account.
  - We should support keys from other stores such as "Epic Games" "ubisoft" etc, so make this generic
  - While I am calling this "saving a steam key" it is important that the user can simply mark that they "own" the game and they have the key stored elsewhere. Optionally, they can elect to store the key in our system (see security section).
  - User has a "search" bar where they can search for the game they are looking to add to their key library
  - User goes to that game's main page, and there is an option to add a steam key
  - They are then brought to the process to save their steam key, which will display the known bundles which have been released for this game.
    - If they select a known bundle we will prefill as much of the form as possible.
    - Some items in this form that are useful: steam_key, region keys are allowed, expiration date, etc
