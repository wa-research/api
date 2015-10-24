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

//----- Parse IDs out of the result
//
let splitRows (s:string) = 
    new StringReader(s) 
    |> Seq.unfold (fun sr -> 
        match sr.ReadLine() with
        | null -> sr.Dispose(); None 
        | str -> Some(str, sr))
    |> Seq.toArray

let readId (s:string) =
    s.Substring(0,8)
    
let mednetApi = 
    { 
        Key = "";
        Pwd =  "";
        BaseUrl = "https://mednet-communities.net/__api/v1/" ;
    }
let scope = "/parent"
let targets = ["/parent/sub1";"/parent/sub2";"/parent/sub3"]

let listMembersOp = 
    {
        Name = "list-members";
        Params = []
    }

let makeAddMemberOp id =
    {
        Name = "add-member";
        Params = [("id", id)]
    }

let acl apiConfig apiOperation scope = 
    (apiRequest apiConfig apiOperation scope) 
        |> getResponseBody 
        |> splitRows 
        |> Seq.map readId
        |> Set.ofSeq

let getAcl = acl mednetApi listMembersOp
let addMember scope id = apiRequest mednetApi (makeAddMemberOp id) scope
let addAllMembers (c, acl) =
    acl |> Set.iter (fun id -> addMember c id |> getResponseBody |> ignore)

let src = getAcl scope
let patches = 
    targets
    |> Seq.map (fun t -> (t, (getAcl t)))
    |> Seq.map (fun (c, acl) -> (c, Set.difference src acl))   

patches |> Seq.iter addAllMembers
