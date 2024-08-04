export const handler = async (event) => {

  console.log(`event: `, event);

  // TODO implement
  const response = {
    statusCode: 200,
    body: JSON.stringify('Reporter 1'),
  };
  return response;
};
