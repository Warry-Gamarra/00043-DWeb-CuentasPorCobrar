using Data.DTO;
using Data.Procedures;
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
        TC_Persona GetByDocIdent(string numDNI, string codTipDoc);

        TC_Persona GetByID(int personaID);
    }
}
