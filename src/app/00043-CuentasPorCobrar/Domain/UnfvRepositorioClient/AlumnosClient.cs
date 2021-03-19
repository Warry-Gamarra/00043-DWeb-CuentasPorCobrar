using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using Newtonsoft.Json;

namespace Domain.UnfvRepositorioClient
{
    public class AlumnosClient : IAlumnosClient
    {
        public IEnumerable<AlumnoModel> GetByDocIdent(string codTipDoc, string numDNI)
        {
            string url, jsonResponse;
            HttpWebRequest request;
            IEnumerable<AlumnoModel> result;

            try
            {
                var uri = UnfvRepositorioClientConfiguration.BaseUrl("alumnos");

                var query = HttpUtility.ParseQueryString(uri.Query);

                query["codTipDoc"] = codTipDoc;

                query["numDNI"] = numDNI;

                uri.Query = query.ToString();

                url = uri.ToString();

                request = (HttpWebRequest)WebRequest.Create(url);
                
                request.Method = HttpVerb.GET.ToString();

                using (var response = (HttpWebResponse)request.GetResponse())
                using (var responseStream = response.GetResponseStream())
                using (var reader = new StreamReader(responseStream))
                {
                    jsonResponse = reader.ReadToEnd();

                    result = JsonConvert.DeserializeObject<List<AlumnoModel>>(jsonResponse);
                }
            }
            catch (WebException ex)
            {
                throw ex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public AlumnoModel GetByID(string codRc, string codAlu)
        {
            string url, jsonResponse;
            HttpWebRequest request;
            AlumnoModel result;

            try
            {
                var uri = UnfvRepositorioClientConfiguration.BaseUrl("alumnos");

                var query = HttpUtility.ParseQueryString(uri.Query);

                query["codRc"] = codRc;

                query["codAlu"] = codAlu;

                uri.Query = query.ToString();

                url = uri.ToString();

                request = (HttpWebRequest)WebRequest.Create(url);

                request.Method = HttpVerb.GET.ToString();

                using (var response = (HttpWebResponse)request.GetResponse())
                using (var responseStream = response.GetResponseStream())
                using (var reader = new StreamReader(responseStream))
                {
                    jsonResponse = reader.ReadToEnd();

                    result = JsonConvert.DeserializeObject<AlumnoModel>(jsonResponse);
                }
            }
            catch (WebException ex)
            {
                throw ex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public IEnumerable<AlumnoModel> GetByCodAlu(string codAlu)
        {
            string url, jsonResponse;
            HttpWebRequest request;
            IEnumerable<AlumnoModel> result;

            try
            {
                var uri = UnfvRepositorioClientConfiguration.BaseUrl("alumnos");

                var query = HttpUtility.ParseQueryString(uri.Query);

                query["codAlu"] = codAlu;

                uri.Query = query.ToString();

                url = uri.ToString();

                request = (HttpWebRequest)WebRequest.Create(url);

                request.Method = HttpVerb.GET.ToString();

                using (var response = (HttpWebResponse)request.GetResponse())
                using (var responseStream = response.GetResponseStream())
                using (var reader = new StreamReader(responseStream))
                {
                    jsonResponse = reader.ReadToEnd();

                    result = JsonConvert.DeserializeObject<List<AlumnoModel>>(jsonResponse);
                }
            }
            catch (WebException ex)
            {
                throw ex;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }
    }
}
