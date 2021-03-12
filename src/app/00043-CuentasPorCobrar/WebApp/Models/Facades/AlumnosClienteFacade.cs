using Domain.UnfvRepositorioClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.Models.Facades
{
    public class AlumnosClienteFacade : IAlumnosClienteFacade
    {
        IAlumnosClient alumnosClient;

        public AlumnosClienteFacade()
        {
            alumnosClient = new AlumnosClient();
        }

        public IEnumerable<AlumnoModel> GetByDocIdent(string codTipDoc, string numDNI)
        {
            return alumnosClient.GetByDocIdent(codTipDoc, numDNI);
        }

        public AlumnoModel GetByID(string codRc, string codAlu)
        {
            return alumnosClient.GetByID(codRc, codAlu);
        }
    }
}