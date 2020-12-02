using Data.Tables;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Repositories
{
    public interface IPersonaRepository
    {
        IEnumerable<TC_Persona> GetByDocIdent(string codTipDoc, string numDNI);

        TC_Persona GetByID(int personaID);
    }
}
