# cosine-cc
Repository for Cosine API, Cosine Loader and Cosine Shell. Cosine is a small multi-accounting and permissions manager for ComputerCraft.

In this repository you'll find:
* [Cosine API](cos-api): lightweight multi-accounting and permission manager for ComputerCraft. **Cosine API** manages the user database using [`bakpakin/binser`](https://github.com/bakpakin/binser) and overwrites the original CC APIs to integrate permission management.
* [Cosine Loader](cos-loader): boot script that manages the execution of **Cosine API** and launches any provided shell.
* [Cosine CL](cos-cl): command line program to interact with **Cosine API**.
* [Cosine Shell](cos-sh): extension of CraftOS's basic shell to include user management.
