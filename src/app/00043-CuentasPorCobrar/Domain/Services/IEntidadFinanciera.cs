using Domain.DTO;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IEntidadFinanciera
    {
        List<EntidadFinanciera> Find();
        EntidadFinanciera Find(int entidadFinanId);
        Response Save(EntidadFinanciera entidadFinanciera, int currentUserId, SaveOption saveOption);
        Response ChangeState(int entidadFinanId, bool currentState, int currentUserId);
        Response HabilitarArchivos(int entidadFinanId, int currentUserId);

    }
}
