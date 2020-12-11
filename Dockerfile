# install stage
FROM node:14-alpine AS base
WORKDIR /base
COPY package*.json tsconfig.json tsconfig.server.json yarn.lock ./
RUN yarn install --frozen-lockfile
COPY . .

#build stage
FROM base as build
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
WORKDIR /build
COPY --from=base /base ./
RUN yarn build

# run stage
FROM node:14-alpine
ENV NODE_ENV=production
WORKDIR /app
COPY --from=build /build/public ./public
COPY --from=build /build/package.json /build/yarn.lock /build/dist ./
COPY --from=build /build/.next ./.next
RUN yarn install --production=true

EXPOSE 3000
CMD ["yarn", "start"]
