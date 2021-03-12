using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.UnfvRepositorioClient
{
    public interface IAlumnosClient
    {
        IEnumerable<AlumnoModel> GetByDocIdent(string codTipDoc, string numDNI);

        AlumnoModel GetByID(string codRc, string codAlu);
    }
}
