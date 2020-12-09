All necessary parts to deploy the backend of Software Architecture project for OSU-like game.

Clone the repository recursively:

```bash
git clone --recurse-submodules ...
```

# How to run

```bash
cd ./docker
docker-compose up --build -d
```

The system can be configured through environment variables, e. g. in `.env` file.
