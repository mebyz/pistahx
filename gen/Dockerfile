FROM google/nodejs
COPY node_modules /src/node_modules
COPY app /src/app
COPY site /src/site
COPY distrib /src/distrib
RUN cd /src/distrib; rm -rf node_modules/microtime ; npm install microtime
RUN cd /src/distrib/node_modules/sequelize; rm -rf node_modules/microtime ; npm install microtime 
EXPOSE  3000
CMD ["node", "/src/distrib/api.js"]
