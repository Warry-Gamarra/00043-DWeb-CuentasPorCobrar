using Domain.Helpers;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace Domain.UnfvRepositorioClient
{
    public class ProgramasClient : IProgramasClient
    {
        public IEnumerable<FacultadModel> GetFacultades()
        {
            string url, jsonResponse;
            HttpWebRequest request;
            IEnumerable<FacultadModel> result;

            try
            {
                var uri = UnfvRepositorioClientConfiguration.BaseUrl("facultades");

                url = uri.ToString();

                request = (HttpWebRequest)WebRequest.Create(url);

                request.Method = HttpVerb.GET.ToString();

                using (var response = (HttpWebResponse)request.GetResponse())
                using (var responseStream = response.GetResponseStream())
                using (var reader = new StreamReader(responseStream))
                {
                    jsonResponse = reader.ReadToEnd();

                    result = JsonConvert.DeserializeObject<List<FacultadModel>>(jsonResponse);
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

        public IEnumerable<EscuelaModel> GetEscuelas(string codFac)
        {
            string url, jsonResponse;
            HttpWebRequest request;
            IEnumerable<EscuelaModel> result;

            try
            {
                if (String.IsNullOrWhiteSpace(codFac))
                {
                    throw new Exception("El código de Facultad es obligatorio.");
                }

                var uri = UnfvRepositorioClientConfiguration.BaseUrl("facultades/" + codFac + "/escuelas");

                url = uri.ToString();

                request = (HttpWebRequest)WebRequest.Create(url);

                request.Method = HttpVerb.GET.ToString();

                using (var response = (HttpWebResponse)request.GetResponse())
                using (var responseStream = response.GetResponseStream())
                using (var reader = new StreamReader(responseStream))
                {
                    jsonResponse = reader.ReadToEnd();

                    result = JsonConvert.DeserializeObject<List<EscuelaModel>>(jsonResponse);
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

        public IEnumerable<EspecialidadModel> GetEspecialidades(string codFac)
        {
            string url, jsonResponse;
            HttpWebRequest request;
            IEnumerable<EspecialidadModel> result;

            try
            {
                if (String.IsNullOrWhiteSpace(codFac))
                {
                    throw new Exception("El código de Facultad es obligatorio.");
                }

                var uri = UnfvRepositorioClientConfiguration.BaseUrl("facultades/" + codFac + "/especialidades");

                url = uri.ToString();

                request = (HttpWebRequest)WebRequest.Create(url);

                request.Method = HttpVerb.GET.ToString();

                using (var response = (HttpWebResponse)request.GetResponse())
                using (var responseStream = response.GetResponseStream())
                using (var reader = new StreamReader(responseStream))
                {
                    jsonResponse = reader.ReadToEnd();

                    result = JsonConvert.DeserializeObject<List<EspecialidadModel>>(jsonResponse);
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

        public IEnumerable<EspecialidadModel> GetEspecialidades(string codFac, string codEsc)
        {
            string url, jsonResponse;
            HttpWebRequest request;
            IEnumerable<EspecialidadModel> result;

            try
            {
                if (String.IsNullOrWhiteSpace(codFac))
                {
                    throw new Exception("El código de Facultad es obligatorio.");
                }

                if (String.IsNullOrWhiteSpace(codEsc))
                {
                    throw new Exception("El código de Escuela es obligatorio.");
                }

                var uri = UnfvRepositorioClientConfiguration.BaseUrl("facultades/" + codFac + "/escuelas/" + codEsc + "/especialidades");

                url = uri.ToString();

                request = (HttpWebRequest)WebRequest.Create(url);

                request.Method = HttpVerb.GET.ToString();

                using (var response = (HttpWebResponse)request.GetResponse())
                using (var responseStream = response.GetResponseStream())
                using (var reader = new StreamReader(responseStream))
                {
                    jsonResponse = reader.ReadToEnd();

                    result = JsonConvert.DeserializeObject<List<EspecialidadModel>>(jsonResponse);
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
