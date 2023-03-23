const logger = console;

exports.handler = async event => {
  logger.info('EVENT', JSON.stringify(event));

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: 'ok',
    }),
  };
};
