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
        ResponseData Create(TC_Persona persona);

        ResponseData Edit(TC_Persona persona);

        IEnumerable<TC_Persona> GetAll();

        TC_Persona GetByID(int I_PersonaID);

        TC_Persona GetByDocIdent(string C_NumDNI, string C_CodTipDoc);
    }
}
