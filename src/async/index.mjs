import { LambdaClient, InvokeCommand } from "@aws-sdk/client-lambda";


export const handler = async (event) => {
  console.log(`event: `, event);
  const client = new LambdaClient({});
  let command = new InvokeCommand({
    FunctionName: "inmoment_terraform_check",
    Payload: JSON.stringify(event, null, 2),
    LogType: "Tail",
     InvocationType: "Event"
  });
  let response = await client.send(command);
  command = new InvokeCommand({
    FunctionName: "inmoment_terraform_metrics",
    Payload: JSON.stringify(event, null, 2),
    LogType: "Tail",
     InvocationType: "Event"
  });
  response = await client.send(command);
  console.log(`response: `, response);

  return {
    statusCode: 200,
    body: JSON.stringify("Async requests created"),
  };
};