export const handler = async (event) => {
  console.log(`event: `, event);

  const response = {
    statusCode: 200,
    body: JSON.stringify('metrics 1'),
  };
  return response;
};
