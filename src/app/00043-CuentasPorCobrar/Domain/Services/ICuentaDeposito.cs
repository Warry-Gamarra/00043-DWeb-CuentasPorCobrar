using Domain.Helpers;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface ICuentaDeposito
    {
        List<CuentaDeposito> Find();
        CuentaDeposito Find(int ctaDepositoId);
        Response Save(CuentaDeposito cuentaDeposito, int currentUserId, SaveOption saveOption);
        Response ChangeState(int ctaDepositoId, bool currentState, int currentUserId);

    }
}
