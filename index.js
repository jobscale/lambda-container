import fs from 'fs';

const logger = console;

const parseLSB = async () => {
  const buffer = fs.readFileSync('/etc/os-release');
  const release = Buffer.from(buffer).toString().replace(/"/g, '');
  const lsb = {};
  release.split('\n').forEach(entry => {
    const [key, value] = entry.split('=');
    lsb[key] = value;
  });
  return lsb;
};

const main = async () => {
  const lsb = await parseLSB();
  return {
    lsb,
    env: process.env,
  };
};

export const handler = async event => {
  logger.info('EVENT', JSON.stringify(event));

  return main(event)
  .then(res => {
    logger.info({ res });
    return {
      statusCode: 200,
      headers: { 'Content-Length': 'application/json' },
      body: JSON.stringify(res),
    };
  })
  .catch(e => {
    logger.error(e);
    return {
      statusCode: 503,
      headers: { 'Content-Length': 'application/json' },
      body: JSON.stringify({ message: e.message }),
    };
  })
  .then(response => {
    logger.info('RESPONSE', JSON.stringify(response));
    return response;
  });
};
