import json
import azure.functions as func

app = func.FunctionApp()

@app.route(route="Ping", methods=["POST"], auth_level=func.AuthLevel.ANONYMOUS)
def Ping(req: func.HttpRequest) -> func.HttpResponse:
        return func.HttpResponse(
            json.dumps("Hello World!"),
            mimetype="application/json"
        )

@app.route(route="Table", methods=["GET"], auth_level=func.AuthLevel.ANONYMOUS)
def Table(req: func.HttpRequest) -> func.HttpResponse:
        hardcoded_table_list = {
                "value": [
                    {
                        "id": "/subscriptions/e594f0cc-7915-4ef7-ab8f-9de56fb28d42/resourceGroups/stefan-mockup/providers/Microsoft.CustomProviders/resourceProviders/public/table/1",
                        "properties": {
                                "id": "1",
                                "key1": "nexus68",
                                "key2": "Dell XR8610t 1U",
                                "key3": "6.10.91.00",
                                "key4": "Enabled (via HTML5)",
                                "key5": "40 Watts",
                                "key6": "45C",
                                "key7": "ssh-rsa AAAB3NzaC1yc2EAAAABJQAAAQB/nAmOjTmezNUDKYvEeIRf2YnwM9/uUG1d0BYsc8/tRtx+RGi7N2lUbp728MXGwdnL9od4cItzky+FGK34qc7PIHmCbEDEIKvfXV+OnC0g4CQHeC3GXPaT8WjCV4IkIxYLAS1Cx4Lno6iXQxSELjKcdb4fGoEpyLRKdz4UCNdFNSmc2te4z1KToZLnZeds1+jvduzI5v17FqnIC5Yil+cQOwwJrElirk8H/q22VXOj80qXldTpYg/cKQMAQGs2sFGNPhZcAIXbsr8SpMeiy/dCo8GZxHrzC/pLxb5cIdnAftn2Zp9huAk5+c3mn5Lhi0wiXpCcUXRbTcHeRWlHkHteURePauQZSQ+q8T7bkMlZ4ZmeYmCba6MMbz07yQqueqYHsM2o1",
                                "key8": "Remote Syslog"
                        }                                           
                    },
                    {
                        "id": "/subscriptions/e594f0cc-7915-4ef7-ab8f-9de56fb28d42/resourceGroups/stefan-mockup/providers/Microsoft.CustomProviders/resourceProviders/public/table/2",
                        "properties": {
                                "id": "2",
                                "key1": "nexus69",
                                "key2": "Dell XR8620t 2U",
                                "key3": "7.00.00.171",
                                "key4": "Enabled (via HTML5)",
                                "key5": "61 Watts",
                                "key6": "62C",
                                "key7": "ssh-rsa AAAOoxK_MgGeeLui385KJ7ZOYktjhLBNAB69fKwTZFsUNh0+BpMRYQ+FGK34qc7PIHmCbEDEIKvfXV+OnC0g4CQHeC3GXPaT8WjCV4IkIxYLAS1Cx4Lno6iXQxSELjKcdb4fGoEpyLRKdz4UCNdFNSmc2te4z1KToZLnZeds1+jvduzI5v17FqnIC5Yil+cQOwwJrElirk8H/q22VXOj80qXldTpYg/cKQMAQGs2sFGNPhZcAIXbsr8SpMeiy/dCo8GZxHrzC/pLxb5cIdnAftn2Zp9huAk5+c3mn5Lhi0wiXpCcUXRbTcHeRWlHkHteURePauQZSQ+q8T7bkMlZ4ZmeYmCba6MMbz07yQqueqYHsM2o1",
                                "key8": "Remote Syslog"
                        }                                           
                    },
                    {
                        "id": "/subscriptions/e594f0cc-7915-4ef7-ab8f-9de56fb28d42/resourceGroups/stefan-mockup/providers/Microsoft.CustomProviders/resourceProviders/public/table/2",
                        "properties": {
                                "id": "3",
                                "key1": "nexus70",
                                "key2": "HPE ProLiant DL320 Gen11",
                                "key3": "20.19.31",
                                "key4": "Enabled (via HTML5)",
                                "key5": "41 Watts",
                                "key6": "45C",
                                "key7": "ssh-rsa AAAAbYSzn3Py6AasNj6nEtCfB+FGK34qc7PIHmCbEDEIKvfXV+OnC0g4CQHeC3GXPaT8WjCV4IkIxYLAS1Cx4Lno6iXQxSELjKcdb4fGoEpyLRKdz4UCNdFNSmc2te4z1KToZLnZeds1+jvduzI5v17FqnIC5Yil+cQOwwJrElirk8H/q22VXOj80qXldTpYg/cKQMAQGs2sFGNPhZcAIXbsr8SpMeiy/dCo8GZxHrzC/pLxb5cIdnAftn2Zp9huAk5+c3mn5Lhi0wiXpCcUXRbTcHeRWlHkHteURePauQZSQ+q8T7bkMlZ4ZmeYmCba6MMbz07yQqueqYHsM2o1",
                                "key8": "Remote Syslog"
                        }                                           
                    },
                    {
                        "id": "/subscriptions/e594f0cc-7915-4ef7-ab8f-9de56fb28d42/resourceGroups/stefan-mockup/providers/Microsoft.CustomProviders/resourceProviders/public/table/2",
                        "properties": {
                                "id": "4",
                                "key1": "nexus71",
                                "key2": "HPE ProLiant DL320 Gen11",
                                "key3": "20.19.31",
                                "key4": "Enabled (via HTML5)",
                                "key5": "38 Watts",
                                "key6": "35C",
                                "key7": "ssh-rsa AAAAIJLixBy2qpFoS4DSmoEmo3qGy0t6z09AIJtH+FGK34qc7PIHmCbEDEIKvfXV+OnC0g4CQHeC3GXPaT8WjCV4IkIxYLAS1Cx4Lno6iXQxSELjKcdb4fGoEpyLRKdz4UCNdFNSmc2te4z1KToZLnZeds1+jvduzI5v17FqnIC5Yil+cQOwwJrElirk8H/q22VXOj80qXldTpYg/cKQMAQGs2sFGNPhZcAIXbsr8SpMeiy/dCo8GZxHrzC/pLxb5cIdnAftn2Zp9huAk5+c3mn5Lhi0wiXpCcUXRbTcHeRWlHkHteURePauQZSQ+q8T7bkMlZ4ZmeYmCba6MMbz07yQqueqYHsM2o1",
                                "key8": "Remote Syslog"
                        }                                           
                    }
                ]
        }

        return func.HttpResponse(
            json.dumps(hardcoded_table_list),
            mimetype="application/json"
        )