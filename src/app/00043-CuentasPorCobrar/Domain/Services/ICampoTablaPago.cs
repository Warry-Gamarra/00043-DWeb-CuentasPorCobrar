using Domain.Entities;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface ICampoTablaPago
    {
        List<CampoTablaPago> Find();
        CampoTablaPago Find(int campoId);
        Response Save(CampoTablaPago campoTablaPago, int currentUserId, SaveOption saveOption);
        Response ChangeState(int campoId, bool currentState, int currentUserId);


        List<string> GetBDTables();
        List<string> GetBDColumns(string tableName);
    }
}
