#if INTERACTIVE
#r "../_lib/HttpClient.dll"
#endif
open System
open System.IO
open System.Web
open System.Security.Cryptography
open HttpClient

type ApiConfig = 
    {
        Key : string;
        Pwd : string;
        BaseUrl : string;
    }

type apiOperation = 
    {
        Name : string;
        Params : (string * string) list;
    }

let apiRequest apiConfig apiOperation scope =
    let sign key pwd operation time =
        let bytes = 
            sprintf "%s%s%s%s" operation key pwd time  
            |> System.Text.Encoding.UTF8.GetBytes 
            |> HashAlgorithm.Create("SHA1").ComputeHash 
            |> BitConverter.ToString
        bytes.Replace("-", "").ToLower()
        
    let requestBody signature key time scope opParams =
        let pairwise (a:string, b:string) =
            HttpUtility.UrlEncode a + "=" + HttpUtility.UrlEncode b
        let concat acc p = 
            let pr = pairwise p
            match acc with 
            | "" -> pr; 
            | _ -> acc + "&" + pr
    
        let (parms:(string * string) list) = [
            ("site-id",key);
            ("request-time",time);
            ("signature",signature);
            ("scope",scope)
            ]
        parms |> List.append opParams |> Seq.fold concat ""  
    
    let time = DateTime.UtcNow.ToString("s")
    let signature = sign apiConfig.Key apiConfig.Pwd apiOperation.Name time
    let apiOpUrl = apiConfig.BaseUrl + apiOperation.Name

    printfn "%s" apiOpUrl

    let request = 
        createRequest Post apiOpUrl
        |> withHeader (ContentType "application/x-www-form-urlencoded")
        |> withBody (requestBody signature apiConfig.Key time scope apiOperation.Params)

    request

